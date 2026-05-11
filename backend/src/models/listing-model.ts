import { z } from "zod";
import { ListingCondition, ListingStatus } from "@prisma/client";

/**
 * @swagger
 * components:
 *   schemas:
 *     CreateListingInput:
 *       type: object
 *       required:
 *         - title
 *         - description
 *         - price
 *       properties:
 *         title:
 *           type: string
 *           maxLength: 140
 *           minLength: 1
 *         description:
 *           type: string
 *           minLength: 1
 *         price:
 *           type: integer
 *           minimum: 0
 *         isFree:
 *           type: boolean
 *           default: false
 *         status:
 *           type: string
 *           enum: [AVAILABLE, RESERVED, SOLD]
 *           default: AVAILABLE
 *         condition:
 *           type: string
 *           enum: [NEW, LIKE_NEW, GOOD, FAIR, POOR]
 *           default: GOOD
 *         categoryId:
 *           type: string
 *           minLength: 1
 *         pickupLocationId:
 *           type: string
 *           minLength: 1
 *         courseCode:
 *           type: string
 *           maxLength: 16
 *           minLength: 1
 *         images:
 *           type: array
 *           items:
 *             type: string
 *             format: uri
 *     UpdateListingInput:
 *       type: object
 *       properties:
 *         title:
 *           type: string
 *         description:
 *           type: string
 *         price:
 *           type: integer
 *         isFree:
 *           type: boolean
 *         status:
 *           type: string
 *         condition:
 *           type: string
 *         categoryId:
 *           type: string
 *         pickupLocationId:
 *           type: string
 *         courseCode:
 *           type: string
 *         images:
 *           type: array
 *           items:
 *             type: string
 *     ListingQueryInput:
 *       type: object
 *       properties:
 *         status:
 *           type: string
 *           enum: [AVAILABLE, RESERVED, SOLD]
 *         categoryId:
 *           type: string
 *         courseCode:
 *           type: string
 *         minPrice:
 *           type: integer
 *         maxPrice:
 *           type: integer
 *         search:
 *           type: string
 */

const listingFieldSchema = {
	title: z.string().trim().min(1).max(140),
	description: z.string().trim().min(1),
	price: z.coerce.number().int().min(0),
	isFree: z.coerce.boolean(),
	status: z.enum(ListingStatus),
	condition: z.enum(ListingCondition),
	categoryId: z.string().trim().min(1),
	pickupLocationId: z.string().trim().min(1),
	courseCode: z.string().trim().min(1).max(16),
	images: z.array(z.string().trim().url()),
};

export const createListingSchema = z.object({
	...listingFieldSchema,
	isFree: listingFieldSchema.isFree.default(false),
	status: listingFieldSchema.status.default(ListingStatus.AVAILABLE),
	condition: listingFieldSchema.condition.default(ListingCondition.GOOD),
	courseCode: listingFieldSchema.courseCode.optional(),
	images: listingFieldSchema.images.default([]),
});

export const updateListingSchema = z.object({
	title: listingFieldSchema.title.optional(),
	description: listingFieldSchema.description.optional(),
	price: listingFieldSchema.price.optional(),
	isFree: listingFieldSchema.isFree.optional(),
	status: listingFieldSchema.status.optional(),
	condition: listingFieldSchema.condition.optional(),
	categoryId: listingFieldSchema.categoryId.optional(),
	pickupLocationId: listingFieldSchema.pickupLocationId.optional(),
	courseCode: listingFieldSchema.courseCode.optional(),
	images: listingFieldSchema.images.optional(),
});

const listingQueryBaseSchema = z.object({
	status: z.enum(ListingStatus).optional(),
	categoryId: z.string().trim().optional(),
	courseCode: z.string().trim().optional(),
	minPrice: z.coerce.number().int().min(0).optional(),
	maxPrice: z.coerce.number().int().min(0).optional(),
});

type ListingQueryRangeInput = z.infer<typeof listingQueryBaseSchema> & {
	search?: string;
};

const validatePriceRange = (data: ListingQueryRangeInput, ctx: z.RefinementCtx): void => {
	if (
		data.minPrice !== undefined &&
		data.maxPrice !== undefined &&
		data.maxPrice < data.minPrice
	) {
		ctx.addIssue({
			code: z.ZodIssueCode.custom,
			message: "maxPrice cannot be less than minPrice",
			path: ["maxPrice"],
		});
	}
};

export const listingQuerySchema = listingQueryBaseSchema
	.extend({
		search: z.string().trim().min(1).optional(),
	})
	.superRefine(validatePriceRange);

export const listingSearchSchema = listingQueryBaseSchema
	.extend({
		search: z.string().trim().min(1),
	})
	.superRefine(validatePriceRange);

export const listingIdSchema = z.object({
	id: z.string().trim().min(1),
});

export type CreateListingInput = z.infer<typeof createListingSchema>;
export type UpdateListingInput = z.infer<typeof updateListingSchema>;
export type ListingQueryInput = z.infer<typeof listingQuerySchema>;
