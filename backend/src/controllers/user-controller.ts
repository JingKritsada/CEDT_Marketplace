import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { ok } from "@/utils/api-response.js";
import { userService } from "@/services/user-service.js";

const getUserId = (id: string | string[]): string => {
	return Array.isArray(id) ? id[0] : id;
};

export const getMe = asyncHandler(async (req: Request, res: Response) => {
	const user = await userService.getById(req.auth!.userId);

	res.status(200).json(ok(user));
});

export const getUserById = asyncHandler(async (req: Request, res: Response) => {
	const user = await userService.getById(getUserId(req.params.id));

	res.status(200).json(ok(user));
});

export const updateMe = asyncHandler(async (req: Request, res: Response) => {
	const user = await userService.updateProfile(req.auth!.userId, req.body);

	res.status(200).json(ok(user));
});
