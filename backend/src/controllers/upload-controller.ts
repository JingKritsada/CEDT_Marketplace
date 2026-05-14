import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { uploadService } from "@/services/upload-service.js";

export const uploadListingImages = asyncHandler(async (req: Request, res: Response) => {
	const files = (req.files as Express.Multer.File[] | undefined) ?? [];
	const urls = await uploadService.saveImages(req, files);

	res.status(201).json({ urls });
});
