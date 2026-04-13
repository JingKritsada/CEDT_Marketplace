import { Router } from "express";

import { getCategories } from "@/controllers/category-controller.js";

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
