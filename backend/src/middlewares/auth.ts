import type { NextFunction, Request, Response } from "express";

import { ApiError } from "@/utils/api-error.js";
import { verifyAccessToken } from "@/utils/token.js";

declare global {
	namespace Express {
		interface Request {
			auth?: {
				userId: string;
				email: string;
			};
		}
	}
}

export const requireAuth = (req: Request, _res: Response, next: NextFunction): void => {
	const authorization = req.header("authorization");

	if (!authorization?.startsWith("Bearer ")) {
		next(new ApiError("Unauthorized", 401));

		return;
	}

	const token = authorization.slice(7);

	try {
		const payload = verifyAccessToken(token);

		req.auth = {
			userId: payload.sub,
			email: payload.email,
		};
		next();
	} catch {
		next(new ApiError("Unauthorized", 401));
	}
};
