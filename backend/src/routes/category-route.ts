import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import { createCategorySchema } from "@/models/category-model.js";
import { createCategory, getCategories } from "@/controllers/category-controller.js";

export const categoryRouter = Router();

/**
 * @swagger
 * /categories:
 *   get:
 *     summary: Get all categories
 *     tags: [Categories]
 *     responses:
 *       200:
 *         description: List of categories
 */
categoryRouter.get("/", getCategories);

/**
 * @swagger
 * /categories:
 *   post:
 *     summary: Create a new category
 *     tags: [Categories]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateCategoryInput'
 *     responses:
 *       201:
 *         description: Category created
 *       400:
 *         description: Validation error or duplicate slug
 */
categoryRouter.post(
	"/",
	writeRateLimit,
	requireAuth,
	validate(createCategorySchema),
	createCategory
);
