import { Router } from "express";
import multer from "multer";

import { requireAuth } from "@/middlewares/auth.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import { uploadListingImages } from "@/controllers/upload-controller.js";

export const uploadRouter = Router();

const storage = multer.memoryStorage();

const upload = multer({
	storage,
	limits: {
		files: 10,
		fileSize: 5 * 1024 * 1024,
	},
});

uploadRouter.post(
	"/images",
	writeRateLimit,
	requireAuth,
	upload.array("images", 10),
	uploadListingImages
);
