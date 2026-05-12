import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     AddCartItemInput:
 *       type: object
 *       required:
 *         - listingId
 *       properties:
 *         listingId:
 *           type: string
 *         quantity:
 *           type: integer
 *           minimum: 1
 *           maximum: 1
 */

export const addCartItemSchema = z.object({
	listingId: z.string().trim().min(1),
	quantity: z.coerce.number().int().min(1).max(1).default(1),
});

export const cartItemIdSchema = z.object({
	listingId: z.string().trim().min(1),
});

export type AddCartItemInput = z.infer<typeof addCartItemSchema>;
