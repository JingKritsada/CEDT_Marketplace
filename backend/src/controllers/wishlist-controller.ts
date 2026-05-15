import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { wishlistService } from "@/services/wishlist-service.js";

const getParamValue = (value: string | string[]): string => {
	return Array.isArray(value) ? value[0] : value;
};

export const getWishlist = asyncHandler(async (req: Request, res: Response) => {
	const wishlist = await wishlistService.getWishlist(req.auth!.userId);

	res.status(200).json(wishlist);
});

export const addWishlistItem = asyncHandler(async (req: Request, res: Response) => {
	const item = await wishlistService.addItem(req.auth!.userId, req.body);

	res.status(201).json(item);
});

export const removeWishlistItem = asyncHandler(async (req: Request, res: Response) => {
	await wishlistService.removeItem(req.auth!.userId, getParamValue(req.params.listingId));

	res.status(204).send();
});

export const clearWishlist = asyncHandler(async (req: Request, res: Response) => {
	await wishlistService.clear(req.auth!.userId);

	res.status(204).send();
});
