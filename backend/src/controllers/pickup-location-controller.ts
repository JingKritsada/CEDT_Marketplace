import type { Request, Response } from "express";

import { pickupLocationService } from "../services/pickup-location-service";
import { asyncHandler } from "../utils/async-handler";

export const getPickupLocations = asyncHandler(async (_req: Request, res: Response) => {
	const pickupLocations = await pickupLocationService.getAll();

	res.status(200).json(pickupLocations);
});
