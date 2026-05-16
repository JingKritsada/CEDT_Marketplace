import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { ok } from "@/utils/api-response.js";
import { reviewService } from "@/services/review-service.js";

export const getReviews = asyncHandler(async (req: Request, res: Response) => {
	const reviews = await reviewService.list(req.query);

	res.status(200).json(ok(reviews));
});

export const createReview = asyncHandler(async (req: Request, res: Response) => {
	const review = await reviewService.create(req.auth!.userId, req.body);

	res.status(201).json(ok(review));
});
