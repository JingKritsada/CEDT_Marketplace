import Stripe from "stripe";

import { ApiError } from "@/utils/api-error.js";

import { env } from "./env.js";

let stripeClient: Stripe | null = null;

export const getStripe = (): Stripe => {
	if (stripeClient) {
		return stripeClient;
	}

	if (!env.STRIPE_SECRET_KEY) {
		throw new ApiError("Stripe is not configured (missing STRIPE_SECRET_KEY)", 503);
	}

	stripeClient = new Stripe(env.STRIPE_SECRET_KEY, {
		apiVersion: env.STRIPE_API_VERSION as Stripe.LatestApiVersion | undefined,
		typescript: true,
	});

	return stripeClient;
};

export const isStripeConfigured = (): boolean => Boolean(env.STRIPE_SECRET_KEY);
