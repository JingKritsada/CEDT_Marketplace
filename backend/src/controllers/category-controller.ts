import type { Request, Response } from "express";

import { categoryService } from "../services/category-service";
import { asyncHandler } from "../utils/async-handler";

export const getCategories = asyncHandler(async (_req: Request, res: Response) => {
	const categories = await categoryService.getAll();

	res.status(200).json(categories);
});
