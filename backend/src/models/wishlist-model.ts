import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     AddWishlistItemInput:
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

export const addWishlistItemSchema = z.object({
	listingId: z.string().trim().min(1),
	quantity: z.coerce.number().int().min(1).max(1).default(1),
});

export const wishlistItemIdSchema = z.object({
	listingId: z.string().trim().min(1),
});

export type AddWishlistItemInput = z.infer<typeof addWishlistItemSchema>;
