import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     CreateCategoryInput:
 *       type: object
 *       required:
 *         - name
 *         - slug
 *       properties:
 *         name:
 *           type: string
 *         slug:
 *           type: string
 */

export const createCategorySchema = z.object({
	name: z.string().trim().min(1),
	slug: z.string().trim().min(1),
});

export type CreateCategoryInput = z.infer<typeof createCategorySchema>;
