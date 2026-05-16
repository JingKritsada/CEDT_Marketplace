import type { NextFunction, Request, Response } from "express";

import { ZodError } from "zod";
import { Prisma } from "@prisma/client";

import { ApiError } from "@/utils/api-error.js";
import { fail } from "@/utils/api-response.js";

export const errorHandler = (
	err: unknown,
	_req: Request,
	res: Response,
	_next: NextFunction
): void => {
	if (err instanceof ApiError) {
		res.status(err.statusCode).json(fail(err.code, err.message, err.details));

		return;
	}

	if (err instanceof ZodError || (err as any)?.name === "ZodError") {
		res
			.status(400)
			.json(
				fail("VALIDATION_FAILED", "Validation failed", (err as any).issues || (err as any).errors)
			);

		return;
	}

	if (err instanceof Prisma.PrismaClientKnownRequestError) {
		const details = process.env.NODE_ENV === "production" ? undefined : err.message;

		res.status(400).json(fail("DATABASE_ERROR", "Database request failed", details));

		return;
	}

	console.error("[error-handler] unhandled error", err);

	const details = process.env.NODE_ENV === "production" ? undefined : (err as Error)?.message;

	res.status(500).json(fail("INTERNAL_ERROR", "Internal server error", details));
};
