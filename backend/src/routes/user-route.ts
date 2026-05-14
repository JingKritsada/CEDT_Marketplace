import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { getMe, getUserById, updateMe } from "@/controllers/user-controller.js";
import { userRateLimit } from "@/middlewares/rate-limit.js";
import { validate } from "@/middlewares/validate.js";
import { updateUserProfileSchema } from "@/models/user-model.js";

export const userRouter = Router();

/**
 * @swagger
 * /users/me:
 *   get:
 *     summary: Get current logged-in user details
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Current user details
 *       401:
 *         description: Unauthorized
 */
userRouter.get("/me", userRateLimit, requireAuth, getMe);

/**
 * @swagger
 * /users/{id}:
 *   get:
 *     summary: Get a public user profile by id
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: Public user profile
 *       404:
 *         description: User not found
 */
userRouter.get("/:id", getUserById);

/**
 * @swagger
 * /users/me:
 *   patch:
 *     summary: Update current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateUserProfileInput'
 *     responses:
 *       200:
 *         description: Updated user profile
 *       401:
 *         description: Unauthorized
 */
userRouter.patch("/me", userRateLimit, requireAuth, validate(updateUserProfileSchema), updateMe);
