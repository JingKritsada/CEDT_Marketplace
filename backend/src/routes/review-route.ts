import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import { createReviewSchema, reviewQuerySchema } from "@/models/review-model.js";
import { createReview, getReviews } from "@/controllers/review-controller.js";

export const reviewRouter = Router();

/**
 * @swagger
 * /reviews:
 *   get:
 *     summary: Get reviews by listing or seller
 *     tags: [Reviews]
 *     parameters:
 *       - in: query
 *         name: listingId
 *         schema:
 *           type: string
 *       - in: query
 *         name: sellerId
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of reviews
 */
reviewRouter.get("/", validate(reviewQuerySchema, "query"), getReviews);

/**
 * @swagger
 * /reviews:
 *   post:
 *     summary: Create a review for a listing
 *     tags: [Reviews]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateReviewInput'
 *     responses:
 *       201:
 *         description: Review created
 *       401:
 *         description: Unauthorized
 */
reviewRouter.post("/", writeRateLimit, requireAuth, validate(createReviewSchema), createReview);
