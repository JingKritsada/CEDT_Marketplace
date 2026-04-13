import { Router } from "express";

import { getPickupLocations } from "@/controllers/pickup-location-controller.js";

export const pickupLocationRouter = Router();

/**
 * @swagger
 * /pickup-locations:
 *   get:
 *     summary: Get all pickup locations
 *     tags: [Pickup Locations]
 *     responses:
 *       200:
 *         description: List of pickup locations
 */
pickupLocationRouter.get("/", getPickupLocations);
