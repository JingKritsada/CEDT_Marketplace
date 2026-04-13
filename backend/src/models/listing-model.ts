import { ListingCondition, ListingStatus } from "@prisma/client";
import { z } from "zod";

export const createListingSchema = z.object({
	title: z.string().trim().min(1).max(140),
	description: z.string().trim().min(1),
	price: z.number().int().min(0),
	isFree: z.boolean().default(false),
	status: z.enum(ListingStatus).optional(),
	condition: z.enum(ListingCondition).default(ListingCondition.GOOD),
	categoryId: z.string().trim().min(1).optional(),
	pickupLocationId: z.string().trim().min(1).optional(),
	courseCode: z.string().trim().min(1).max(16).optional(),
	images: z.array(z.url()).default([]),
});

export const updateListingSchema = createListingSchema.partial();

export const listingQuerySchema = z.object({
	status: z.enum(ListingStatus).optional(),
	categoryId: z.string().trim().min(1).optional(),
	courseCode: z.string().trim().min(1).optional(),
	minPrice: z.coerce.number().int().min(0).optional(),
	maxPrice: z.coerce.number().int().min(0).optional(),
	search: z.string().trim().min(1).optional(),
});

export const listingIdSchema = z.object({
	id: z.string().trim().min(1),
});

export type CreateListingInput = z.infer<typeof createListingSchema>;
export type UpdateListingInput = z.infer<typeof updateListingSchema>;
export type ListingQueryInput = z.infer<typeof listingQuerySchema>;
