import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { getMe } from "@/controllers/user-controller.js";
import { userRateLimit } from "@/middlewares/rate-limit.js";

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
