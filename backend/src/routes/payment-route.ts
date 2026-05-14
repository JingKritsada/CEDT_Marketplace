import { Router } from "express";

import {
	cancelPayment,
	createCheckout,
	getPayment,
	listMyPayments,
	refundPayment,
} from "@/controllers/payment-controller.js";
import { checkoutSchema, paymentIdSchema, refundSchema } from "@/models/payment-model.js";
import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";

export const paymentRouter = Router();

/**
 * @swagger
 * /checkout:
 *   post:
 *     summary: Start checkout for a listing — creates a manual-capture PaymentIntent
 *     tags: [Payments]
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/CheckoutInput' }
 *     responses:
 *       201: { description: clientSecret + publishableKey }
 */
export const checkoutRouter = Router();

checkoutRouter.post("/", writeRateLimit, requireAuth, validate(checkoutSchema), createCheckout);

/**
 * @swagger
 * /payments:
 *   get:
 *     summary: List the current user's payments (as buyer or seller)
 *     tags: [Payments]
 *     security: [{ bearerAuth: [] }]
 */
paymentRouter.get("/", requireAuth, listMyPayments);

/**
 * @swagger
 * /payments/{id}:
 *   get:
 *     summary: Get a single payment by id
 *     tags: [Payments]
 *     security: [{ bearerAuth: [] }]
 */
paymentRouter.get("/:id", requireAuth, validate(paymentIdSchema, "params"), getPayment);

/**
 * @swagger
 * /payments/{id}/cancel:
 *   post:
 *     summary: Buyer cancels a payment before capture
 *     tags: [Payments]
 *     security: [{ bearerAuth: [] }]
 */
paymentRouter.post(
	"/:id/cancel",
	writeRateLimit,
	requireAuth,
	validate(paymentIdSchema, "params"),
	cancelPayment
);

/**
 * @swagger
 * /payments/{id}/refund:
 *   post:
 *     summary: Seller refunds a captured payment
 *     tags: [Payments]
 *     security: [{ bearerAuth: [] }]
 */
paymentRouter.post(
	"/:id/refund",
	writeRateLimit,
	requireAuth,
	validate(paymentIdSchema, "params"),
	validate(refundSchema),
	refundPayment
);
