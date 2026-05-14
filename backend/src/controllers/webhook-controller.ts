import type { Request, Response } from "express";

import { stripeService } from "@/services/stripe-service.js";
import { webhookService } from "@/services/webhook-service.js";

export const handleStripeWebhook = async (req: Request, res: Response): Promise<void> => {
	const signature = req.header("stripe-signature");

	if (!signature) {
		res.status(400).json({ message: "Missing stripe-signature header" });

		return;
	}

	let event;

	try {
		event = stripeService.constructEvent(req.body as Buffer, signature);
	} catch (err) {
		const message = err instanceof Error ? err.message : "Invalid webhook signature";

		res.status(400).json({ message });

		return;
	}

	try {
		await webhookService.handleEvent(event);
		res.status(200).json({ received: true });
	} catch (err) {
		// Returning 500 makes Stripe retry — that's the desired behavior on transient errors.
		console.error("[stripe webhook] handler error", { id: event.id, type: event.type, err });
		res.status(500).json({ message: "Webhook handler failed" });
	}
};
