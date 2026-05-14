import { Router } from "express";

import {
	getMySellerBalance,
	getMySellerProfile,
	listMySellerPayouts,
	refreshSellerStatus,
	startSellerOnboarding,
} from "@/controllers/seller-onboarding-controller.js";
import { requireAuth } from "@/middlewares/auth.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";

export const sellerOnboardingRouter = Router();

/**
 * @swagger
 * /sellers/onboarding:
 *   post:
 *     summary: Start (or resume) Stripe Connect onboarding for the current user
 *     tags: [Sellers]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200: { description: Onboarding URL + connect account id }
 */
sellerOnboardingRouter.post("/onboarding", writeRateLimit, requireAuth, startSellerOnboarding);

/**
 * @swagger
 * /sellers/onboarding/refresh:
 *   post:
 *     summary: Force re-sync seller profile from Stripe
 *     tags: [Sellers]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200: { description: Updated SellerProfile }
 */
sellerOnboardingRouter.post("/onboarding/refresh", requireAuth, refreshSellerStatus);

/**
 * @swagger
 * /sellers/me:
 *   get:
 *     summary: Get current user's SellerProfile
 *     tags: [Sellers]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200: { description: SellerProfile }
 */
sellerOnboardingRouter.get("/me", requireAuth, getMySellerProfile);

/**
 * @swagger
 * /sellers/me/balance:
 *   get:
 *     summary: Live Stripe balance for the current seller's connected account
 *     tags: [Sellers]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200: { description: Stripe balance object }
 */
sellerOnboardingRouter.get("/me/balance", requireAuth, getMySellerBalance);

/**
 * @swagger
 * /sellers/me/payouts:
 *   get:
 *     summary: Live list of Stripe payouts for the current seller
 *     tags: [Sellers]
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200: { description: Stripe payouts list }
 */
sellerOnboardingRouter.get("/me/payouts", requireAuth, listMySellerPayouts);
