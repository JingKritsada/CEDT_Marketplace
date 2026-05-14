import type Stripe from "stripe";

import {
	ListingStatus,
	PaymentStatus,
	Prisma,
	RefundStatus,
	SellerConnectStatus,
} from "@prisma/client";

import { env } from "@/config/env.js";
import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import { stripeService } from "@/services/stripe-service.js";

const mapRefundStatus = (status: string | null | undefined): RefundStatus => {
	switch (status) {
		case "succeeded":
			return RefundStatus.SUCCEEDED;
		case "failed":
		case "canceled":
			return RefundStatus.FAILED;
		default:
			return RefundStatus.PENDING;
	}
};

const PI_STATUS_MAP: Record<Stripe.PaymentIntent.Status, PaymentStatus> = {
	requires_payment_method: PaymentStatus.REQUIRES_PAYMENT_METHOD,
	requires_confirmation: PaymentStatus.REQUIRES_PAYMENT_METHOD,
	requires_action: PaymentStatus.REQUIRES_ACTION,
	processing: PaymentStatus.PROCESSING,
	requires_capture: PaymentStatus.REQUIRES_CAPTURE,
	succeeded: PaymentStatus.SUCCEEDED,
	canceled: PaymentStatus.CANCELED,
};

const calcPlatformFee = (amountSatang: number): number =>
	Math.floor((amountSatang * env.PLATFORM_FEE_BPS) / 10000);

const includePaymentForResponse = {
	listing: { select: { id: true, title: true, images: true, price: true } },
	seller: { select: { id: true, displayName: true, avatarUrl: true } },
	buyer: { select: { id: true, displayName: true, avatarUrl: true } },
	refunds: true,
} as const;

export const paymentService = {
	async checkout(buyerId: string, listingId: string) {
		const listing = await prisma.listing.findUnique({
			where: { id: listingId },
			include: {
				seller: {
					select: {
						id: true,
						sellerProfile: true,
					},
				},
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}
		if (listing.isFree || listing.price <= 0) {
			throw new ApiError("Listing is free and cannot be checked out", 400);
		}
		if (listing.sellerId === buyerId) {
			throw new ApiError("You cannot buy your own listing", 400);
		}
		if (listing.status !== ListingStatus.AVAILABLE) {
			throw new ApiError("Listing is not available", 409);
		}

		const sellerProfile = listing.seller.sellerProfile;

		if (
			!sellerProfile ||
			sellerProfile.connectStatus !== SellerConnectStatus.ACTIVE ||
			!sellerProfile.payoutsEnabled ||
			!sellerProfile.chargesEnabled ||
			!sellerProfile.stripeConnectAccountId
		) {
			throw new ApiError("Seller cannot accept payments yet", 409);
		}

		const amountSatang = listing.price;
		const platformFeeSatang = calcPlatformFee(amountSatang);
		const sellerNetSatang = amountSatang - platformFeeSatang;

		// Race-safe flip BEFORE calling Stripe. updateMany returns count=0 if status changed.
		const flipped = await prisma.listing.updateMany({
			where: { id: listing.id, status: ListingStatus.AVAILABLE },
			data: { status: ListingStatus.WAITING_FOR_PAYMENT },
		});

		if (flipped.count === 0) {
			throw new ApiError("Listing is no longer available", 409);
		}

		let paymentIntent: Stripe.PaymentIntent;

		try {
			paymentIntent = await stripeService.createPaymentIntent({
				amountSatang,
				platformFeeSatang,
				sellerStripeAccountId: sellerProfile.stripeConnectAccountId,
				listingId: listing.id,
				buyerId,
				idempotencyKey: `checkout:${listing.id}:${buyerId}:${Date.now()}`,
			});
		} catch (err) {
			await prisma.listing.updateMany({
				where: { id: listing.id, status: ListingStatus.WAITING_FOR_PAYMENT },
				data: { status: ListingStatus.AVAILABLE },
			});
			throw err;
		}

		try {
			const payment = await prisma.$transaction(async (tx) => {
				const created = await tx.payment.create({
					data: {
						buyerId,
						sellerId: listing.sellerId,
						listingId: listing.id,
						stripePaymentIntentId: paymentIntent.id,
						amountSatang,
						platformFeeSatang,
						sellerNetSatang,
						currency: paymentIntent.currency,
						status:
							PI_STATUS_MAP[paymentIntent.status] ??
							PaymentStatus.REQUIRES_PAYMENT_METHOD,
						captureMethod: paymentIntent.capture_method ?? "manual",
					},
				});

				await tx.listing.update({
					where: { id: listing.id },
					data: { currentPaymentIntentId: paymentIntent.id },
				});

				return created;
			});

			return {
				paymentId: payment.id,
				paymentIntentId: paymentIntent.id,
				clientSecret: paymentIntent.client_secret,
				publishableKey: env.STRIPE_PUBLISHABLE_KEY ?? null,
				amountSatang,
				platformFeeSatang,
				currency: paymentIntent.currency,
			};
		} catch (err) {
			// Best-effort rollback if the DB step failed after Stripe created the PI.
			await stripeService.cancelPaymentIntent(paymentIntent.id).catch(() => {});
			await prisma.listing.updateMany({
				where: { id: listing.id, status: ListingStatus.WAITING_FOR_PAYMENT },
				data: { status: ListingStatus.AVAILABLE, currentPaymentIntentId: null },
			});
			throw err;
		}
	},

	async getById(paymentId: string, userId: string) {
		const payment = await prisma.payment.findUnique({
			where: { id: paymentId },
			include: includePaymentForResponse,
		});

		if (!payment) {
			throw new ApiError("Payment not found", 404);
		}
		if (payment.buyerId !== userId && payment.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		return payment;
	},

	async listForUser(userId: string) {
		return prisma.payment.findMany({
			where: { OR: [{ buyerId: userId }, { sellerId: userId }] },
			include: includePaymentForResponse,
			orderBy: { createdAt: "desc" },
		});
	},

	async cancel(paymentId: string, userId: string) {
		const payment = await prisma.payment.findUnique({ where: { id: paymentId } });

		if (!payment) {
			throw new ApiError("Payment not found", 404);
		}
		if (payment.buyerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		const cancelable: PaymentStatus[] = [
			PaymentStatus.REQUIRES_PAYMENT_METHOD,
			PaymentStatus.REQUIRES_ACTION,
			PaymentStatus.PROCESSING,
			PaymentStatus.REQUIRES_CAPTURE,
		];

		if (!cancelable.includes(payment.status)) {
			throw new ApiError("Payment cannot be canceled in its current state", 400);
		}

		await stripeService.cancelPaymentIntent(payment.stripePaymentIntentId);

		// Real state change will arrive via payment_intent.canceled webhook.
		// Reflect optimistically here for fast UI response.
		return prisma.payment.update({
			where: { id: payment.id },
			data: { status: PaymentStatus.CANCELED, canceledAt: new Date() },
		});
	},

	async confirmReceiptForListing(listingId: string, userId: string) {
		const listing = await prisma.listing.findUnique({ where: { id: listingId } });

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}
		if (listing.buyerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		const captureableListingStatuses: ListingStatus[] = [
			ListingStatus.PAID,
			ListingStatus.WAITING_FOR_PICKUP,
			ListingStatus.SENT,
		];

		if (!captureableListingStatuses.includes(listing.status)) {
			throw new ApiError("Listing is not ready to confirm receipt", 400);
		}
		if (!listing.currentPaymentIntentId) {
			throw new ApiError("No active payment to capture", 400);
		}

		const payment = await prisma.payment.findUnique({
			where: { stripePaymentIntentId: listing.currentPaymentIntentId },
		});

		if (!payment) {
			throw new ApiError("Payment record missing for listing", 500);
		}
		if (payment.status !== PaymentStatus.REQUIRES_CAPTURE) {
			throw new ApiError(`Payment is not in a capturable state (${payment.status})`, 400);
		}

		const captured = await stripeService.capturePaymentIntent(payment.stripePaymentIntentId);

		return prisma.$transaction(async (tx) => {
			const updatedPayment = await tx.payment.update({
				where: { id: payment.id },
				data: {
					status: PI_STATUS_MAP[captured.status] ?? PaymentStatus.SUCCEEDED,
					capturedAt: new Date(),
					succeededAt: captured.status === "succeeded" ? new Date() : null,
				},
			});

			const updatedListing = await tx.listing.update({
				where: { id: listing.id },
				data: { status: ListingStatus.RECEIVED, buyerId: userId },
			});

			return { payment: updatedPayment, listing: updatedListing };
		});
	},

	async refund(paymentId: string, userId: string, amountSatang?: number, reason?: string) {
		const payment = await prisma.payment.findUnique({ where: { id: paymentId } });

		if (!payment) {
			throw new ApiError("Payment not found", 404);
		}
		if (payment.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}
		if (
			payment.status !== PaymentStatus.SUCCEEDED &&
			payment.status !== PaymentStatus.PARTIALLY_REFUNDED
		) {
			throw new ApiError("Payment cannot be refunded in its current state", 400);
		}

		await stripeService.createRefund({
			paymentIntentId: payment.stripePaymentIntentId,
			amountSatang,
			reason,
		});

		// Final refund state arrives via charge.refunded + transfer.reversed webhooks.
		return payment;
	},

	// ---- Webhook helpers (idempotent updates) ----

	async applyPaymentIntentUpdate(pi: Stripe.PaymentIntent) {
		const payment = await prisma.payment.findUnique({
			where: { stripePaymentIntentId: pi.id },
		});

		if (!payment) {
			return null;
		}

		const status = PI_STATUS_MAP[pi.status] ?? payment.status;
		const data: Prisma.PaymentUpdateInput = {
			status,
			paymentMethodType:
				typeof pi.payment_method === "string" ? null : (pi.payment_method?.type ?? null),
			failureCode: pi.last_payment_error?.code ?? null,
			failureMessage: pi.last_payment_error?.message ?? null,
		};

		if (pi.status === "succeeded") {
			data.succeededAt = new Date();
			if (!payment.capturedAt) {
				data.capturedAt = new Date();
			}
		}
		if (pi.status === "canceled") {
			data.canceledAt = new Date();
		}

		await prisma.payment.update({ where: { id: payment.id }, data });

		if (pi.status === "requires_capture") {
			await prisma.listing.updateMany({
				where: { id: payment.listingId, currentPaymentIntentId: pi.id },
				data: { status: ListingStatus.PAID, buyerId: payment.buyerId },
			});
		}

		if (pi.status === "canceled") {
			await prisma.listing.updateMany({
				where: { id: payment.listingId, currentPaymentIntentId: pi.id },
				data: { status: ListingStatus.AVAILABLE, currentPaymentIntentId: null },
			});
		}

		return payment;
	},

	async markPaymentIntentFailed(pi: Stripe.PaymentIntent) {
		const payment = await prisma.payment.findUnique({
			where: { stripePaymentIntentId: pi.id },
		});

		if (!payment) {
			return null;
		}

		await prisma.payment.update({
			where: { id: payment.id },
			data: {
				status: PaymentStatus.FAILED,
				failureCode: pi.last_payment_error?.code ?? null,
				failureMessage: pi.last_payment_error?.message ?? null,
			},
		});

		await prisma.listing.updateMany({
			where: { id: payment.listingId, currentPaymentIntentId: pi.id },
			data: { status: ListingStatus.AVAILABLE, currentPaymentIntentId: null },
		});

		return payment;
	},

	async applyChargeUpdate(charge: Stripe.Charge) {
		if (!charge.payment_intent || typeof charge.payment_intent !== "string") {
			return null;
		}

		const applicationFeeId =
			typeof charge.application_fee === "string"
				? charge.application_fee
				: (charge.application_fee?.id ?? null);

		const result = await prisma.payment.updateMany({
			where: { stripePaymentIntentId: charge.payment_intent },
			data: {
				stripeChargeId: charge.id,
				...(applicationFeeId ? { stripeApplicationFeeId: applicationFeeId } : {}),
			},
		});

		return result.count > 0;
	},

	async applyChargeRefunded(charge: Stripe.Charge) {
		if (!charge.payment_intent || typeof charge.payment_intent !== "string") {
			return null;
		}

		const payment = await prisma.payment.findUnique({
			where: { stripePaymentIntentId: charge.payment_intent },
		});

		if (!payment) {
			return null;
		}

		const fullyRefunded = charge.amount_refunded >= charge.amount;
		const newStatus = fullyRefunded ? PaymentStatus.REFUNDED : PaymentStatus.PARTIALLY_REFUNDED;

		await prisma.payment.update({
			where: { id: payment.id },
			data: { status: newStatus },
		});

		for (const refund of charge.refunds?.data ?? []) {
			const status = mapRefundStatus(refund.status);

			await prisma.refund.upsert({
				where: { stripeRefundId: refund.id },
				create: {
					stripeRefundId: refund.id,
					paymentId: payment.id,
					amountSatang: refund.amount,
					reason: refund.reason ?? null,
					status,
				},
				update: {
					amountSatang: refund.amount,
					status,
				},
			});
		}

		return payment;
	},

	async markTransferReversed(transferId: string) {
		const payment = await prisma.payment.findFirst({
			where: { stripeTransferId: transferId },
			include: { refunds: true },
		});

		if (!payment) {
			return null;
		}

		await prisma.sellerProfile.update({
			where: { userId: payment.sellerId },
			data: {
				totalEarnedSatang: { decrement: BigInt(payment.sellerNetSatang) },
			},
		});

		await prisma.refund.updateMany({
			where: { paymentId: payment.id },
			data: { reverseTransfer: true },
		});

		return payment;
	},

	async markApplicationFeeRefunded(applicationFeeId: string) {
		const payment = await prisma.payment.findFirst({
			where: { stripeApplicationFeeId: applicationFeeId },
		});

		if (!payment) {
			return null;
		}

		await prisma.refund.updateMany({
			where: { paymentId: payment.id },
			data: { refundApplicationFee: true },
		});

		return payment;
	},

	async recordTransferCreated(transfer: Stripe.Transfer) {
		const piId = transfer.source_transaction;

		if (!piId || typeof piId !== "string") {
			return null;
		}

		// source_transaction is a charge ID, not a PI. Look up Payment by charge.
		const payment = await prisma.payment.findFirst({
			where: { stripeChargeId: piId },
		});

		if (!payment) {
			return null;
		}

		await prisma.payment.update({
			where: { id: payment.id },
			data: { stripeTransferId: transfer.id },
		});

		await prisma.sellerProfile.update({
			where: { userId: payment.sellerId },
			data: { totalEarnedSatang: { increment: BigInt(payment.sellerNetSatang) } },
		});

		return payment;
	},

	async recordApplicationFeeCreated(fee: Stripe.ApplicationFee) {
		if (!fee.charge || typeof fee.charge !== "string") {
			return null;
		}

		return prisma.payment.updateMany({
			where: { stripeChargeId: fee.charge },
			data: { stripeApplicationFeeId: fee.id },
		});
	},
};
