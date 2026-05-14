import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     CreatePickupLocationInput:
 *       type: object
 *       required:
 *         - name
 *         - building
 *       properties:
 *         name:
 *           type: string
 *         building:
 *           type: string
 *         description:
 *           type: string
 */

export const createPickupLocationSchema = z.object({
	name: z.string().trim().min(1),
	building: z.string().trim().min(1),
	description: z.string().trim().min(1).optional(),
});

export type CreatePickupLocationInput = z.infer<typeof createPickupLocationSchema>;
