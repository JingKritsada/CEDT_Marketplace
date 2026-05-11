import { Router } from "express";

import {
	createListing,
	deleteListing,
	getListingById,
	getListings,
	searchListings,
	updateListing,
} from "@/controllers/listing-controller.js";
import {
	createListingSchema,
	listingIdSchema,
	listingQuerySchema,
	listingSearchSchema,
	updateListingSchema,
} from "@/models/listing-model.js";
import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";

export const listingRouter = Router();

/**
 * @swagger
 * /listings:
 *   get:
 *     summary: Get all listings with optional filtering
 *     tags: [Listings]
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *       - in: query
 *         name: categoryId
 *         schema:
 *           type: string
 *       - in: query
 *         name: courseCode
 *         schema:
 *           type: string
 *       - in: query
 *         name: minPrice
 *         schema:
 *           type: integer
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: integer
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of listings
 */
listingRouter.get("/", validate(listingQuerySchema, "query"), getListings);

/**
 * @swagger
 * /listings/search:
 *   get:
 *     summary: Search for listings
 *     tags: [Listings]
 *     parameters:
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *           required: true
 *     responses:
 *       200:
 *         description: Search results
 */
listingRouter.get("/search", validate(listingSearchSchema, "query"), searchListings);

/**
 * @swagger
 * /listings/{id}:
 *   get:
 *     summary: Get a listing by ID
 *     tags: [Listings]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Listing details
 *       404:
 *         description: Listing not found
 */
listingRouter.get("/:id", validate(listingIdSchema, "params"), getListingById);

/**
 * @swagger
 * /listings:
 *   post:
 *     summary: Create a new listing
 *     tags: [Listings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, description, price]
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               price:
 *                 type: number
 *               isFree:
 *                 type: boolean
 *               status:
 *                 type: string
 *               condition:
 *                 type: string
 *               categoryId:
 *                 type: string
 *               pickupLocationId:
 *                 type: string
 *               courseCode:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Listing created
 *       401:
 *         description: Unauthorized
 */
listingRouter.post("/", writeRateLimit, requireAuth, validate(createListingSchema), createListing);

/**
 * @swagger
 * /listings/{id}:
 *   patch:
 *     summary: Update an existing listing
 *     tags: [Listings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       optional: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               price:
 *                 type: number
 *               isFree:
 *                 type: boolean
 *               status:
 *                 type: string
 *               condition:
 *                 type: string
 *               categoryId:
 *                 type: string
 *               pickupLocationId:
 *                 type: string
 *               courseCode:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Listing updated
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Not found
 */
listingRouter.patch(
	"/:id",
	writeRateLimit,
	requireAuth,
	validate(listingIdSchema, "params"),
	validate(updateListingSchema),
	updateListing
);

/**
 * @swagger
 * /listings/{id}:
 *   delete:
 *     summary: Delete a listing
 *     tags: [Listings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       204:
 *         description: Listing deleted
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Not found
 */
listingRouter.delete(
	"/:id",
	writeRateLimit,
	requireAuth,
	validate(listingIdSchema, "params"),
	deleteListing
);
