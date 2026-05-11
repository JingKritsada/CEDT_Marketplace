import { Prisma } from "@prisma/client";

import type {
	CreateListingInput,
	ListingQueryInput,
	UpdateListingInput,
} from "@/models/listing-model.js";
import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";

const buildFilter = (query: ListingQueryInput): Prisma.ListingWhereInput => {
	const where: Prisma.ListingWhereInput = {};

	if (query.status) {
		where.status = query.status;
	}

	if (query.categoryId) {
		where.categoryId = query.categoryId;
	}

	if (query.courseCode) {
		where.courseCode = query.courseCode;
	}

	if (query.search) {
		where.OR = [
			{
				title: {
					contains: query.search,
					mode: "insensitive",
				},
			},
			{
				description: {
					contains: query.search,
					mode: "insensitive",
				},
			},
		];
	}

	if (query.minPrice !== undefined || query.maxPrice !== undefined) {
		const priceFilter: Prisma.IntFilter = {};

		if (query.minPrice !== undefined) {
			priceFilter.gte = query.minPrice;
		}

		if (query.maxPrice !== undefined) {
			priceFilter.lte = query.maxPrice;
		}

		where.price = priceFilter;
	}

	return where;
};

const getListingOrThrow = async (id: string) => {
	const listing = await prisma.listing.findUnique({
		where: { id },
		include: {
			seller: {
				select: {
					id: true,
					email: true,
					displayName: true,
					avatarUrl: true,
				},
			},
			category: true,
			pickupLocation: true,
		},
	});

	if (!listing) {
		throw new ApiError("Listing not found", 404);
	}

	return listing;
};

export const listingService = {
	async getAll(query: ListingQueryInput) {
		return prisma.listing.findMany({
			where: buildFilter(query),
			include: {
				seller: {
					select: {
						id: true,
						displayName: true,
					},
				},
				category: true,
				pickupLocation: true,
			},
			orderBy: {
				createdAt: "desc",
			},
		});
	},

	async search(query: ListingQueryInput) {
		// if (!query.search) {
		// 	throw new ApiError("Search query parameter is required", 400);
		// }

		return this.getAll(query);
	},

	async getById(id: string) {
		return getListingOrThrow(id);
	},

	async create(userId: string, payload: CreateListingInput) {
		return prisma.listing.create({
			data: {
				...payload,
				sellerId: userId,
			},
			include: {
				seller: {
					select: {
						id: true,
						displayName: true,
					},
				},
				category: true,
				pickupLocation: true,
			},
		});
	},

	async update(id: string, userId: string, payload: UpdateListingInput) {
		const listing = await prisma.listing.findUnique({
			where: { id },
			select: {
				id: true,
				sellerId: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (listing.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		return prisma.listing.update({
			where: { id },
			data: payload,
			include: {
				seller: {
					select: {
						id: true,
						displayName: true,
					},
				},
				category: true,
				pickupLocation: true,
			},
		});
	},

	async remove(id: string, userId: string) {
		const listing = await prisma.listing.findUnique({
			where: { id },
			select: {
				id: true,
				sellerId: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (listing.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		await prisma.listing.delete({
			where: { id },
		});
	},
};
