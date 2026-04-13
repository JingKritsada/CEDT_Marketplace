import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { categoryService } from "@/services/category-service.js";

export const getCategories = asyncHandler(async (_req: Request, res: Response) => {
	const categories = await categoryService.getAll();

	res.status(200).json(categories);
});
