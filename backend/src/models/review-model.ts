import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     CreateReviewInput:
 *       type: object
 *       required:
 *         - listingId
 *         - rating
 *       properties:
 *         listingId:
 *           type: string
 *         rating:
 *           type: integer
 *           minimum: 1
 *           maximum: 5
 *         comment:
 *           type: string
 */

export const createReviewSchema = z.object({
	listingId: z.string().trim().min(1),
	rating: z.coerce.number().int().min(1).max(5),
	comment: z.string().trim().min(1).max(1000).optional(),
});

export const reviewQuerySchema = z.object({
	listingId: z.string().trim().min(1).optional(),
	sellerId: z.string().trim().min(1).optional(),
});

export type CreateReviewInput = z.infer<typeof createReviewSchema>;
export type ReviewQueryInput = z.infer<typeof reviewQuerySchema>;
