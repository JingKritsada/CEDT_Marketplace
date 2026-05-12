import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     UpdateUserProfileInput:
 *       type: object
 *       properties:
 *         displayName:
 *           type: string
 *         avatarUrl:
 *           type: string
 *           format: uri
 *         lineId:
 *           type: string
 *         instagram:
 *           type: string
 *         facebookUrl:
 *           type: string
 *           format: uri
 */

export const updateUserProfileSchema = z.object({
	displayName: z.string().trim().min(1).max(80).optional(),
	avatarUrl: z.string().url().optional(),
	lineId: z.string().trim().min(1).max(64).optional(),
	instagram: z.string().trim().min(1).max(64).optional(),
	facebookUrl: z.string().url().optional(),
});

export type UpdateUserProfileInput = z.infer<typeof updateUserProfileSchema>;
