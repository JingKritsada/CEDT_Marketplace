import type { NextFunction, Request, Response } from "express";

import { ZodError } from "zod";
import { Prisma } from "@prisma/client";

import { ApiError } from "@/utils/api-error.js";

export const errorHandler = (
	err: unknown,
	_req: Request,
	res: Response,
	_next: NextFunction
): void => {
	console.error("Error caught by Global Handler:", err);

	if (err instanceof ApiError) {
		res.status(err.statusCode).json({
			message: err.message,
			details: err.details,
		});

		return;
	}

	if (err instanceof ZodError || (err as any)?.name === "ZodError") {
		res.status(400).json({
			message: "Validation failed",
			details: (err as any).issues || (err as any).errors,
		});

		return;
	}

	if (err instanceof Prisma.PrismaClientKnownRequestError) {
		const details = process.env.NODE_ENV === "production" ? undefined : err.message;

		res.status(400).json({
			message: "Database request failed",
			details,
		});

		return;
	}

	res.status(500).json({
		message: "Internal server error",
	});
};
