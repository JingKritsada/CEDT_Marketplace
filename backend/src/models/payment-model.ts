import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     CheckoutInput:
 *       type: object
 *       required:
 *         - listingId
 *       properties:
 *         listingId:
 *           type: string
 *     RefundInput:
 *       type: object
 *       properties:
 *         amountSatang:
 *           type: integer
 *           minimum: 1
 *         reason:
 *           type: string
 */

export const checkoutSchema = z.object({
	listingId: z.string().trim().min(1),
});

export const paymentIdSchema = z.object({
	id: z.string().trim().min(1),
});

export const refundSchema = z.object({
	amountSatang: z.coerce.number().int().min(1).optional(),
	reason: z.enum(["duplicate", "fraudulent", "requested_by_customer"]).optional(),
});

export type CheckoutInput = z.infer<typeof checkoutSchema>;
export type RefundInput = z.infer<typeof refundSchema>;
