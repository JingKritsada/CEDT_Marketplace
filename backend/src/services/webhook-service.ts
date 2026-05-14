import type Stripe from "stripe";

import { Prisma } from "@prisma/client";

import { prisma } from "@/config/prisma.js";
import { paymentService } from "@/services/payment-service.js";
import { sellerOnboardingService } from "@/services/seller-onboarding-service.js";

const DUPLICATE_KEY_ERROR = "P2002";

/**
 * Returns `true` if this event was new and processed, `false` if it was a duplicate.
 */
export const webhookService = {
	async handleEvent(event: Stripe.Event): Promise<boolean> {
		try {
			await prisma.stripeWebhookEvent.create({
				data: {
					id: event.id,
					type: event.type,
					payload: event as unknown as Prisma.InputJsonValue,
				},
			});
		} catch (err) {
			if (
				err instanceof Prisma.PrismaClientKnownRequestError &&
				err.code === DUPLICATE_KEY_ERROR
			) {
				return false;
			}
			throw err;
		}

		await dispatch(event);

		return true;
	},
};

async function dispatch(event: Stripe.Event): Promise<void> {
	switch (event.type) {
		case "payment_intent.requires_action":
		case "payment_intent.processing":
		case "payment_intent.amount_capturable_updated":
		case "payment_intent.succeeded":
		case "payment_intent.canceled": {
			await paymentService.applyPaymentIntentUpdate(
				event.data.object as Stripe.PaymentIntent
			);

			return;
		}

		case "payment_intent.payment_failed": {
			await paymentService.markPaymentIntentFailed(event.data.object as Stripe.PaymentIntent);

			return;
		}

		case "charge.succeeded":
		case "charge.captured": {
			await paymentService.applyChargeUpdate(event.data.object as Stripe.Charge);

			return;
		}

		case "charge.refunded": {
			await paymentService.applyChargeRefunded(event.data.object as Stripe.Charge);

			return;
		}

		case "charge.dispute.created": {
			// TODO: freeze listing + admin alert. For now we just persist via the event row.
			return;
		}

		case "application_fee.created": {
			await paymentService.recordApplicationFeeCreated(
				event.data.object as Stripe.ApplicationFee
			);

			return;
		}

		case "application_fee.refunded": {
			const fee = event.data.object as Stripe.ApplicationFee;

			await paymentService.markApplicationFeeRefunded(fee.id);

			return;
		}

		case "transfer.created": {
			await paymentService.recordTransferCreated(event.data.object as Stripe.Transfer);

			return;
		}

		case "transfer.reversed": {
			const transfer = event.data.object as Stripe.Transfer;

			await paymentService.markTransferReversed(transfer.id);

			return;
		}

		case "account.updated": {
			await sellerOnboardingService.applyAccountUpdate(event.data.object as Stripe.Account);

			return;
		}

		case "payout.paid": {
			const payout = event.data.object as Stripe.Payout;
			const stripeAccountId = event.account;

			if (stripeAccountId) {
				await sellerOnboardingService.addPaidOut(stripeAccountId, payout.amount);
			}

			return;
		}

		case "payout.failed": {
			// TODO: notify seller + admin alert.
			return;
		}

		default:
			// Acknowledge but ignore.
			return;
	}
}
