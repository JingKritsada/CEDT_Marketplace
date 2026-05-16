import { Router } from "express";

import { validate } from "@/middlewares/validate.js";
import { authRateLimit } from "@/middlewares/rate-limit.js";
import { login, refresh, register, logout } from "@/controllers/auth-controller.js";
import {
	appleNativeLogin,
	facebookCallback,
	facebookStart,
	googleCallback,
	googleStart,
} from "@/controllers/oauth-controller.js";
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

/**
 * @swagger
 * /auth/oauth/google/start:
 *   get:
 *     summary: Begin Google OAuth flow (redirects to Google)
 *     tags: [Auth]
 *     responses:
 *       302:
 *         description: Redirect to Google's authorization endpoint
 */
authRouter.get("/oauth/google/start", googleStart);

/**
 * @swagger
 * /auth/oauth/google/callback:
 *   get:
 *     summary: Google OAuth callback (redirects to mobile app with tokens)
 *     tags: [Auth]
 *     responses:
 *       302:
 *         description: Redirect to mobile app deep link with tokens in URL fragment
 */
authRouter.get("/oauth/google/callback", googleCallback);

/**
 * @swagger
 * /auth/oauth/facebook/start:
 *   get:
 *     summary: Begin Facebook OAuth flow (redirects to Facebook)
 *     tags: [Auth]
 */
authRouter.get("/oauth/facebook/start", facebookStart);

/**
 * @swagger
 * /auth/oauth/facebook/callback:
 *   get:
 *     summary: Facebook OAuth callback (redirects to mobile app with tokens)
 *     tags: [Auth]
 */
authRouter.get("/oauth/facebook/callback", facebookCallback);

/**
 * @swagger
 * /auth/social/apple:
 *   post:
 *     summary: Native Apple Sign-in (iOS posts Apple's identityToken)
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [identityToken]
 *             properties:
 *               identityToken:
 *                 type: string
 *               fullName:
 *                 type: object
 *                 properties:
 *                   givenName: { type: string }
 *                   familyName: { type: string }
 *     responses:
 *       200:
 *         description: Authenticated, returns access + refresh tokens
 */
authRouter.post("/social/apple", authRateLimit, appleNativeLogin);
