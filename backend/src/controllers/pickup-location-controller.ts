import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { ok } from "@/utils/api-response.js";
import { pickupLocationService } from "@/services/pickup-location-service.js";

export const getPickupLocations = asyncHandler(async (_req: Request, res: Response) => {
	const pickupLocations = await pickupLocationService.getAll();

	res.status(200).json(ok(pickupLocations));
});

export const createPickupLocation = asyncHandler(async (req: Request, res: Response) => {
	const pickupLocation = await pickupLocationService.create(req.body);

	res.status(201).json(ok(pickupLocation));
});
