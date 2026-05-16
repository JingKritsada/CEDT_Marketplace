import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { ok } from "@/utils/api-response.js";
import { listingService } from "@/services/listing-service.js";
import { paymentService } from "@/services/payment-service.js";

const getListingId = (id: string | string[]): string => {
	return Array.isArray(id) ? id[0] : id;
};

export const getListings = asyncHandler(async (req: Request, res: Response) => {
	const listings = await listingService.getAll(req.query);

	res.status(200).json(ok(listings));
});

export const searchListings = asyncHandler(async (req: Request, res: Response) => {
	const listings = await listingService.search(req.query);

	res.status(200).json(ok(listings));
});

export const getListingById = asyncHandler(async (req: Request, res: Response) => {
	const listing = await listingService.getById(getListingId(req.params.id));

	res.status(200).json(ok(listing));
});

export const createListing = asyncHandler(async (req: Request, res: Response) => {
	const listing = await listingService.create(req.auth!.userId, req.body);

	res.status(201).json(ok(listing));
});

export const updateListing = asyncHandler(async (req: Request, res: Response) => {
	const listing = await listingService.update(
		getListingId(req.params.id),
		req.auth!.userId,
		req.body
	);

	res.status(200).json(ok(listing));
});

export const deleteListing = asyncHandler(async (req: Request, res: Response) => {
	await listingService.remove(getListingId(req.params.id), req.auth!.userId);

	res.status(204).send();
});

export const claimFreeListing = asyncHandler(async (req: Request, res: Response) => {
	const updated = await listingService.claimFree(getListingId(req.params.id), req.auth!.userId);

	res.status(200).json(ok(updated));
});

export const confirmListingReceived = asyncHandler(async (req: Request, res: Response) => {
	const listingId = getListingId(req.params.id);
	const userId = req.auth!.userId;

	// If there's an active PaymentIntent on this listing, capture it (manual-capture flow);
	// otherwise this is a free listing — just flip the status.
	const listing = await listingService.peek(listingId);

	if (listing?.currentPaymentIntentId) {
		const result = await paymentService.confirmReceiptForListing(listingId, userId);

		// Unwrap to match the free-listing branch's response shape (Listing) — the
		// iOS client always decodes this endpoint as a Listing.
		res.status(200).json(ok(result.listing));

		return;
	}

	const updated = await listingService.confirmReceived(listingId, userId);

	res.status(200).json(ok(updated));
});
