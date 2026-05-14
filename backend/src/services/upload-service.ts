import type { Request } from "express";

import { createWriteStream } from "node:fs";
import { mkdir } from "node:fs/promises";
import path from "node:path";
import { randomUUID } from "node:crypto";

import { ApiError } from "@/utils/api-error.js";

const uploadRoot = path.join(process.cwd(), "public", "uploads", "listings");

const extensionByMimeType: Record<string, string> = {
	"image/jpeg": ".jpg",
	"image/png": ".png",
	"image/webp": ".webp",
	"image/gif": ".gif",
	"image/heic": ".heic",
	"image/heif": ".heif",
};

const ensureUploadDirectory = async () => {
	await mkdir(uploadRoot, { recursive: true });
};

const buildPublicUrl = (req: Request, fileName: string) => {
	const baseUrl = `${req.protocol}://${req.get("host")}`;

	return `${baseUrl}/uploads/listings/${fileName}`;
};

export const uploadService = {
	async saveImages(req: Request, files: Express.Multer.File[]) {
		if (!files.length) {
			throw new ApiError("No image files provided", 400);
		}

		await ensureUploadDirectory();

		const urls: string[] = [];

		for (const file of files) {
			if (!file.mimetype.startsWith("image/")) {
				throw new ApiError("Only image files are allowed", 400);
			}

			const extension =
				extensionByMimeType[file.mimetype] ?? path.extname(file.originalname) ?? ".jpg";
			const fileName = `${randomUUID()}${extension}`;
			const filePath = path.join(uploadRoot, fileName);

			await new Promise<void>((resolve, reject) => {
				const stream = createWriteStream(filePath);

				stream.on("error", reject);
				stream.on("finish", resolve);
				stream.end(file.buffer);
			});

			urls.push(buildPublicUrl(req, fileName));
		}

		return urls;
	},
};
