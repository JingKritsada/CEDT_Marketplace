import type { NextFunction, Request, Response } from "express";
import { Prisma } from "@prisma/client";
import { ZodError } from "zod";

import { ApiError } from "../utils/api-error";

export const errorHandler = (
	err: unknown,
	_req: Request,
	res: Response,
	_next: NextFunction
): void => {
	if (err instanceof ApiError) {
		res.status(err.statusCode).json({
			message: err.message,
			details: err.details,
		});
		return;
	}

	if (err instanceof ZodError) {
		res.status(400).json({
			message: "Validation failed",
			details: err.issues,
		});
		return;
	}

	if (err instanceof Prisma.PrismaClientKnownRequestError) {
		res.status(400).json({
			message: "Database request failed",
			details: err.message,
		});
		return;
	}

	res.status(500).json({
		message: "Internal server error",
	});
};
