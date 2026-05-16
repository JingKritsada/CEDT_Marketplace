import type { Request, Response } from "express";

import { fail } from "@/utils/api-response.js";

export const notFoundHandler = (_req: Request, res: Response): void => {
	res.status(404).json(fail("NOT_FOUND", "Route not found"));
};
