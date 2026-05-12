import { Router } from "express";

import { validate } from "@/middlewares/validate.js";
import { authRateLimit } from "@/middlewares/rate-limit.js";
import { login, refresh, register, logout } from "@/controllers/auth-controller.js";
import {
	loginSchema,
	registerSchema,
	logoutSchema,
	refreshTokenSchema,
} from "@/models/auth-model.js";

export const authRouter = Router();

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterInput'
 *     responses:
 *       201:
 *         description: User registered successfully
 *       400:
 *         description: Validation error or Email already registered
 */
authRouter.post("/register", authRateLimit, validate(registerSchema), register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginInput'
 *     responses:
 *       200:
 *         description: Login successful
 *       400:
 *         description: Invalid credentials
 */
authRouter.post("/login", authRateLimit, validate(loginSchema), login);

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Refresh authentication token
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RefreshTokenInput'
 *     responses:
 *       200:
 *         description: Token refreshed
 */
authRouter.post("/refresh", authRateLimit, validate(refreshTokenSchema), refresh);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RefreshTokenInput'
 *     responses:
 *       200:
 *         description: Logged out successfully
 */
authRouter.post("/logout", authRateLimit, validate(logoutSchema), logout);
