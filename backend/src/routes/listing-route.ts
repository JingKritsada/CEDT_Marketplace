import { Router } from "express";

import {
	createListing,
	deleteListing,
	getListingById,
	getListings,
	searchListings,
	updateListing,
} from "../controllers/listing-controller";
import { requireAuth } from "../middlewares/auth";
import { validate } from "../middlewares/validate";
import {
	createListingSchema,
	listingIdSchema,
	listingQuerySchema,
	updateListingSchema,
} from "../models/listing-model";

export const listingRouter = Router();

listingRouter.get("/", validate(listingQuerySchema, "query"), getListings);
listingRouter.get("/search", validate(listingQuerySchema, "query"), searchListings);
listingRouter.get("/:id", validate(listingIdSchema, "params"), getListingById);
listingRouter.post("/", requireAuth, validate(createListingSchema), createListing);
listingRouter.patch(
	"/:id",
	requireAuth,
	validate(listingIdSchema, "params"),
	validate(updateListingSchema),
	updateListing
);
listingRouter.delete("/:id", requireAuth, validate(listingIdSchema, "params"), deleteListing);
