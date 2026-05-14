import type Stripe from "stripe";

import { env } from "@/config/env.js";
import { getStripe } from "@/config/stripe.js";

const COUNTRY = "TH";
const CURRENCY = "thb";

export const stripeService = {
	get client(): Stripe {
		return getStripe();
	},

	async createConnectedAccount(email: string): Promise<Stripe.Account> {
		// Thailand restriction: the *platform* cannot bear payment losses, but
		// Express dashboards require it to. Resolve by using Standard accounts,
		// where the connected seller bears loss liability (allowed in TH) and
		// gets the full Stripe dashboard. Destination charges + application
		// fees still work identically.
		return getStripe().accounts.create({
			type: "standard",
			country: COUNTRY,
			email,
			business_type: "individual",
			default_currency: CURRENCY,
		});
	},

	async createAccountLink(stripeAccountId: string): Promise<Stripe.AccountLink> {
		return getStripe().accountLinks.create({
			account: stripeAccountId,
			type: "account_onboarding",
			return_url: env.STRIPE_CONNECT_RETURN_URL,
			refresh_url: env.STRIPE_CONNECT_REFRESH_URL,
		});
	},

	async retrieveAccount(stripeAccountId: string): Promise<Stripe.Account> {
		return getStripe().accounts.retrieve(stripeAccountId);
	},

	async retrieveBalance(stripeAccountId: string): Promise<Stripe.Balance> {
		return getStripe().balance.retrieve({ stripeAccount: stripeAccountId });
	},

	async listPayouts(stripeAccountId: string, limit = 20): Promise<Stripe.ApiList<Stripe.Payout>> {
		return getStripe().payouts.list({ limit }, { stripeAccount: stripeAccountId });
	},

	async createPaymentIntent(params: {
		amountSatang: number;
		platformFeeSatang: number;
		sellerStripeAccountId: string;
		listingId: string;
		buyerId: string;
		idempotencyKey: string;
	}): Promise<Stripe.PaymentIntent> {
		return getStripe().paymentIntents.create(
			{
				amount: params.amountSatang,
				currency: CURRENCY,
				capture_method: "manual",
				// PromptPay is push-payment (QR transfer) and does not support manual
				// capture. Our escrow flow relies on manual capture at pickup-confirm
				// time, so card-only for now. To re-enable PromptPay, switch this PI
				// to auto-capture (and lose the escrow guarantee for those orders).
				payment_method_types: ["card"],
				application_fee_amount: params.platformFeeSatang,
				transfer_data: { destination: params.sellerStripeAccountId },
				on_behalf_of: params.sellerStripeAccountId,
				metadata: {
					listingId: params.listingId,
					buyerId: params.buyerId,
				},
			},
			{ idempotencyKey: params.idempotencyKey }
		);
	},

	async capturePaymentIntent(
		paymentIntentId: string,
		amountToCaptureSatang?: number
	): Promise<Stripe.PaymentIntent> {
		return getStripe().paymentIntents.capture(paymentIntentId, {
			amount_to_capture: amountToCaptureSatang,
		});
	},

	async cancelPaymentIntent(paymentIntentId: string): Promise<Stripe.PaymentIntent> {
		return getStripe().paymentIntents.cancel(paymentIntentId);
	},

	async retrievePaymentIntent(paymentIntentId: string): Promise<Stripe.PaymentIntent> {
		return getStripe().paymentIntents.retrieve(paymentIntentId);
	},

	async createRefund(params: {
		paymentIntentId: string;
		amountSatang?: number;
		reason?: string;
	}): Promise<Stripe.Refund> {
		return getStripe().refunds.create({
			payment_intent: params.paymentIntentId,
			amount: params.amountSatang,
			reason: params.reason as Stripe.RefundCreateParams.Reason | undefined,
			reverse_transfer: true,
			refund_application_fee: true,
		});
	},

	constructEvent(rawBody: Buffer | string, signature: string): Stripe.Event {
		if (!env.STRIPE_WEBHOOK_SECRET) {
			throw new Error("STRIPE_WEBHOOK_SECRET not configured");
		}

		return getStripe().webhooks.constructEvent(rawBody, signature, env.STRIPE_WEBHOOK_SECRET);
	},
};
