import { ListingStatus, Prisma } from "@prisma/client";

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
		where.price = {
			gte:
				query.minPrice && !isNaN(Number(query.minPrice))
					? Number(query.minPrice)
					: undefined,
			lte:
				query.maxPrice && !isNaN(Number(query.maxPrice))
					? Number(query.maxPrice)
					: undefined,
		};
	}

	return where;
};

const statusTransitions: Record<ListingStatus, ListingStatus[]> = {
	AVAILABLE: [
		ListingStatus.RESERVED,
		ListingStatus.WAITING_FOR_PAYMENT,
		ListingStatus.WAITING_FOR_PICKUP,
		ListingStatus.SOLD,
	],
	RESERVED: [
		ListingStatus.AVAILABLE,
		ListingStatus.WAITING_FOR_PAYMENT,
		ListingStatus.WAITING_FOR_PICKUP,
		ListingStatus.SOLD,
	],
	WAITING_FOR_PAYMENT: [ListingStatus.PAID, ListingStatus.AVAILABLE],
	PAID: [ListingStatus.WAITING_FOR_PICKUP, ListingStatus.SENT],
	WAITING_FOR_PICKUP: [ListingStatus.SENT, ListingStatus.RECEIVED],
	SENT: [ListingStatus.RECEIVED],
	RECEIVED: [ListingStatus.RATED],
	RATED: [],
	SOLD: [ListingStatus.WAITING_FOR_PICKUP, ListingStatus.SENT, ListingStatus.RECEIVED],
};

const ensureListingReferences = async (payload: CreateListingInput | UpdateListingInput) => {
	if (payload.categoryId) {
		const category = await prisma.category.findUnique({
			where: { id: payload.categoryId },
			select: { id: true },
		});

		if (!category) {
			throw new ApiError("Category not found", 404);
		}
	}

	if (payload.pickupLocationId) {
		const pickupLocation = await prisma.pickupLocation.findUnique({
			where: { id: payload.pickupLocationId },
			select: { id: true },
		});

		if (!pickupLocation) {
			throw new ApiError("Pickup location not found", 404);
		}
	}
};

const normalizePrice = (payload: CreateListingInput | UpdateListingInput) => {
	if (payload.isFree) {
		if (payload.price && payload.price > 0) {
			throw new ApiError("Free listings must have a price of 0", 400);
		}
		payload.price = 0;
	} else if (payload.price === 0) {
		payload.isFree = true;
	}
};

const getListingOrThrow = async (id: string) => {
	const listing = await prisma.listing.findUnique({
		where: { id },
		include: {
			seller: {
				select: {
					id: true,
					displayName: true,
					avatarUrl: true,
					lineId: true,
					instagram: true,
					facebookUrl: true,
				},
			},
			buyer: {
				select: {
					id: true,
					displayName: true,
					avatarUrl: true,
					lineId: true,
					instagram: true,
					facebookUrl: true,
				},
			},
			category: true,
			pickupLocation: true,
			reviews: {
				include: {
					reviewer: {
						select: {
							id: true,
							displayName: true,
							avatarUrl: true,
							lineId: true,
							instagram: true,
							facebookUrl: true,
						},
					},
				},
				orderBy: {
					createdAt: "desc",
				},
			},
		},
	});

	if (!listing) {
		throw new ApiError("Listing not found", 404);
	}

	return listing;
};

export const listingService = {
	async peek(id: string) {
		return prisma.listing.findUnique({
			where: { id },
			select: {
				id: true,
				sellerId: true,
				buyerId: true,
				status: true,
				currentPaymentIntentId: true,
			},
		});
	},

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
				buyer: {
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
		normalizePrice(payload);
		await ensureListingReferences(payload);

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
				buyer: {
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
				buyerId: true,
				status: true,
				isFree: true,
				price: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (listing.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		if (payload.buyerId && payload.buyerId !== listing.buyerId) {
			const buyer = await prisma.user.findUnique({
				where: { id: payload.buyerId },
				select: { id: true },
			});

			if (!buyer) {
				throw new ApiError("Buyer not found", 404);
			}
		}

		if (payload.status && payload.status !== listing.status) {
			const allowed = statusTransitions[listing.status] ?? [];

			if (!allowed.includes(payload.status)) {
				throw new ApiError(
					`Invalid status transition from ${listing.status} to ${payload.status}`,
					400
				);
			}
		}

		normalizePrice(payload);
		await ensureListingReferences(payload);

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
				buyer: {
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

	async claimFree(id: string, userId: string) {
		const listing = await prisma.listing.findUnique({
			where: { id },
			select: {
				id: true,
				sellerId: true,
				status: true,
				isFree: true,
				price: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (!listing.isFree && listing.price > 0) {
			throw new ApiError("This listing is not free", 400);
		}

		if (listing.sellerId === userId) {
			throw new ApiError("You cannot claim your own listing", 400);
		}

		if (listing.status !== ListingStatus.AVAILABLE) {
			throw new ApiError("Listing is not available", 400);
		}

		return prisma.listing.update({
			where: { id },
			data: {
				status: ListingStatus.WAITING_FOR_PICKUP,
				buyerId: userId,
			},
			include: {
				seller: { select: { id: true, displayName: true } },
				buyer: { select: { id: true, displayName: true } },
				category: true,
				pickupLocation: true,
			},
		});
	},

	async confirmReceived(id: string, userId: string) {
		const listing = await prisma.listing.findUnique({
			where: { id },
			select: {
				id: true,
				buyerId: true,
				status: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (!listing.buyerId || listing.buyerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		if (
			listing.status !== ListingStatus.SENT &&
			listing.status !== ListingStatus.WAITING_FOR_PICKUP
		) {
			throw new ApiError("Listing is not ready to confirm receipt", 400);
		}

		return prisma.listing.update({
			where: { id },
			data: {
				status: ListingStatus.RECEIVED,
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
