import type Stripe from "stripe";

import { SellerConnectStatus } from "@prisma/client";

import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import { stripeService } from "@/services/stripe-service.js";

const deriveConnectStatus = (account: Stripe.Account): SellerConnectStatus => {
	const disabled = account.requirements?.disabled_reason ?? null;

	if (disabled && disabled.startsWith("rejected")) {
		return SellerConnectStatus.REJECTED;
	}
	if (account.charges_enabled && account.payouts_enabled) {
		return SellerConnectStatus.ACTIVE;
	}
	if (disabled) {
		return SellerConnectStatus.RESTRICTED;
	}

	return SellerConnectStatus.PENDING;
};

const toSellerProfileUpdate = (account: Stripe.Account) => ({
	chargesEnabled: account.charges_enabled ?? false,
	payoutsEnabled: account.payouts_enabled ?? false,
	detailsSubmitted: account.details_submitted ?? false,
	requirementsDisabledReason: account.requirements?.disabled_reason ?? null,
	requirementsCurrentlyDue: account.requirements?.currently_due ?? [],
	connectStatus: deriveConnectStatus(account),
});

const ensureProfile = async (userId: string) => {
	const user = await prisma.user.findUnique({
		where: { id: userId },
		select: { id: true, email: true, sellerProfile: true },
	});

	if (!user) {
		throw new ApiError("User not found", 404);
	}

	if (user.sellerProfile) {
		return { user, profile: user.sellerProfile };
	}

	const profile = await prisma.sellerProfile.create({
		data: { userId: user.id },
	});

	return { user, profile };
};

export const sellerOnboardingService = {
	async startOnboarding(userId: string) {
		const { user, profile } = await ensureProfile(userId);

		let stripeAccountId = profile.stripeConnectAccountId;

		if (!stripeAccountId) {
			const account = await stripeService.createConnectedAccount(user.email);

			stripeAccountId = account.id;

			await prisma.sellerProfile.update({
				where: { id: profile.id },
				data: {
					stripeConnectAccountId: stripeAccountId,
					...toSellerProfileUpdate(account),
				},
			});
		}

		const link = await stripeService.createAccountLink(stripeAccountId);

		return {
			url: link.url,
			expiresAt: link.expires_at,
			stripeConnectAccountId: stripeAccountId,
		};
	},

	async refreshFromStripe(userId: string) {
		const { profile } = await ensureProfile(userId);

		if (!profile.stripeConnectAccountId) {
			throw new ApiError("No connected Stripe account; start onboarding first", 400);
		}

		const account = await stripeService.retrieveAccount(profile.stripeConnectAccountId);

		return prisma.sellerProfile.update({
			where: { id: profile.id },
			data: toSellerProfileUpdate(account),
		});
	},

	async getMyProfile(userId: string) {
		const { profile } = await ensureProfile(userId);

		return profile;
	},

	async getMyBalance(userId: string) {
		const { profile } = await ensureProfile(userId);

		if (!profile.stripeConnectAccountId) {
			throw new ApiError("No connected Stripe account", 400);
		}

		return stripeService.retrieveBalance(profile.stripeConnectAccountId);
	},

	async listMyPayouts(userId: string) {
		const { profile } = await ensureProfile(userId);

		if (!profile.stripeConnectAccountId) {
			throw new ApiError("No connected Stripe account", 400);
		}

		return stripeService.listPayouts(profile.stripeConnectAccountId);
	},

	// Used by webhook handler.
	async applyAccountUpdate(account: Stripe.Account) {
		const profile = await prisma.sellerProfile.findUnique({
			where: { stripeConnectAccountId: account.id },
		});

		if (!profile) {
			return null;
		}

		return prisma.sellerProfile.update({
			where: { id: profile.id },
			data: toSellerProfileUpdate(account),
		});
	},

	async addPaidOut(stripeAccountId: string, amountSatang: number) {
		const profile = await prisma.sellerProfile.findUnique({
			where: { stripeConnectAccountId: stripeAccountId },
		});

		if (!profile) {
			return null;
		}

		return prisma.sellerProfile.update({
			where: { id: profile.id },
			data: {
				totalPaidOutSatang: { increment: BigInt(amountSatang) },
			},
		});
	},
};
