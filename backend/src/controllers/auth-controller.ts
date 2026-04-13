import type { Request, Response } from "express";

import { authService } from "../services/auth-service";
import { asyncHandler } from "../utils/async-handler";

export const login = asyncHandler(async (req: Request, res: Response) => {
	const result = await authService.login(req.body);

	res.status(200).json(result);
});

export const refresh = asyncHandler(async (req: Request, res: Response) => {
	const result = await authService.refresh(req.body.refreshToken);

	res.status(200).json(result);
});
