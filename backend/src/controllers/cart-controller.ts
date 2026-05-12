import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { cartService } from "@/services/cart-service.js";

const getParamValue = (value: string | string[]): string => {
	return Array.isArray(value) ? value[0] : value;
};

export const getCart = asyncHandler(async (req: Request, res: Response) => {
	const cart = await cartService.getCart(req.auth!.userId);

	res.status(200).json(cart);
});

export const addCartItem = asyncHandler(async (req: Request, res: Response) => {
	const item = await cartService.addItem(req.auth!.userId, req.body);

	res.status(201).json(item);
});

export const removeCartItem = asyncHandler(async (req: Request, res: Response) => {
	await cartService.removeItem(req.auth!.userId, getParamValue(req.params.listingId));

	res.status(204).send();
});

export const clearCart = asyncHandler(async (req: Request, res: Response) => {
	await cartService.clear(req.auth!.userId);

	res.status(204).send();
});
