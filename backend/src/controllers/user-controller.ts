import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { userService } from "@/services/user-service.js";

export const getMe = asyncHandler(async (req: Request, res: Response) => {
	const user = await userService.getById(req.auth!.userId);

	res.status(200).json(user);
});
