import type { Request, Response } from "express";

import { listingService } from "../services/listing-service";
import { asyncHandler } from "../utils/async-handler";

const getListingId = (id: string | string[]): string => {
	return Array.isArray(id) ? id[0] : id;
};

export const getListings = asyncHandler(async (req: Request, res: Response) => {
	const listings = await listingService.getAll(req.query);

	res.status(200).json(listings);
});

export const searchListings = asyncHandler(async (req: Request, res: Response) => {
	const listings = await listingService.search(req.query);

	res.status(200).json(listings);
});

export const getListingById = asyncHandler(async (req: Request, res: Response) => {
	const listing = await listingService.getById(getListingId(req.params.id));

	res.status(200).json(listing);
});

export const createListing = asyncHandler(async (req: Request, res: Response) => {
	const listing = await listingService.create(req.auth!.userId, req.body);

	res.status(201).json(listing);
});

export const updateListing = asyncHandler(async (req: Request, res: Response) => {
	const listing = await listingService.update(
		getListingId(req.params.id),
		req.auth!.userId,
		req.body
	);

	res.status(200).json(listing);
});

export const deleteListing = asyncHandler(async (req: Request, res: Response) => {
	await listingService.remove(getListingId(req.params.id), req.auth!.userId);

	res.status(204).send();
});
