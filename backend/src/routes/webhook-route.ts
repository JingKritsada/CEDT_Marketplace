import express, { Router } from "express";

import { handleStripeWebhook } from "@/controllers/webhook-controller.js";

export const webhookRouter = Router();

// MUST receive the raw body so the signature can be verified.
// This router is mounted in app.ts BEFORE the global express.json() middleware.
webhookRouter.post(
	"/stripe",
	express.raw({ type: "application/json", limit: "1mb" }),
	handleStripeWebhook
);
