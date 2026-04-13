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
 *           enum: [AVAILABLE, PENDING, SOLD]
 *           default: AVAILABLE
 *         condition:
 *           type: string
 *           enum: [LIKE_NEW, GOOD, FAIR, POOR, FOR_PARTS]
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
 *           enum: [AVAILABLE, PENDING, SOLD]
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

export const createListingSchema = z.object({
	title: z.string().trim().min(1).max(140),
	description: z.string().trim().min(1),
	price: z.number().int().min(0),
	isFree: z.boolean().default(false),
	status: z.enum(ListingStatus).default(ListingStatus.AVAILABLE),
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
