import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     LoginInput:
 *       type: object
 *       required:
 *         - email
 *         - password
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *         password:
 *           type: string
 *           minLength: 8
 *     RefreshTokenInput:
 *       type: object
 *       required:
 *         - refreshToken
 *       properties:
 *         refreshToken:
 *           type: string
 *           minLength: 1
 *     RegisterInput:
 *       type: object
 *       required:
 *         - studentId
 *         - email
 *         - displayName
 *         - password
 *       properties:
 *         studentId:
 *           type: string
 *         email:
 *           type: string
 *           format: email
 *         displayName:
 *           type: string
 *         password:
 *           type: string
 *           minLength: 8
 */

export const loginSchema = z.object({
	email: z.string().trim().toLowerCase().email(),
	password: z.string().min(8),
});

export const refreshTokenSchema = z.object({
	refreshToken: z.string().min(1),
});

export const registerSchema = z.object({
	studentId: z.string().trim().min(1),
	email: z.string().trim().toLowerCase().email(),
	displayName: z.string().trim().min(1),
	password: z.string().min(8),
});

export const logoutSchema = refreshTokenSchema;

export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
