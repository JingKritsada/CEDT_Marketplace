import { Router } from "express";

import { getPickupLocations } from "../controllers/pickup-location-controller";

export const pickupLocationRouter = Router();

pickupLocationRouter.get("/", getPickupLocations);
