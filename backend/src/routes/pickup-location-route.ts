import { Router } from "express";

import {
	createPickupLocation,
	getPickupLocations,
} from "@/controllers/pickup-location-controller.js";
import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import { createPickupLocationSchema } from "@/models/pickup-location-model.js";

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

/**
 * @swagger
 * /pickup-locations:
 *   post:
 *     summary: Create a new pickup location
 *     tags: [Pickup Locations]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreatePickupLocationInput'
 *     responses:
 *       201:
 *         description: Pickup location created
 *       400:
 *         description: Validation error
 */
pickupLocationRouter.post(
	"/",
	writeRateLimit,
	requireAuth,
	validate(createPickupLocationSchema),
	createPickupLocation
);
