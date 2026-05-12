import type { RequestHandler } from "express";
import type { ZodTypeAny } from "zod";

export const validate =
	<T extends ZodTypeAny>(
		schema: T,
		target: "body" | "query" | "params" = "body"
	): RequestHandler =>
	(req, _res, next) => {
		const result = schema.safeParse(req[target]);

		if (!result.success) {
			next(result.error);

			return;
		}
		Object.assign(req[target] as object, result.data);

		next();
	};
