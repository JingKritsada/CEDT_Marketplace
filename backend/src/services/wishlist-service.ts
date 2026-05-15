import { ListingStatus } from "@prisma/client";

import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { AddWishlistItemInput } from "@/models/wishlist-model.js";

const getOrCreateWishlist = async (userId: string) => {
	return prisma.wishlist.upsert({
		where: { userId },
		update: {},
		create: { userId },
	});
};

export const wishlistService = {
	async getWishlist(userId: string) {
		const wishlist = await getOrCreateWishlist(userId);

		return prisma.wishlist.findUnique({
			where: { id: wishlist.id },
			include: {
				items: {
					include: {
						listing: {
							include: {
								category: true,
								pickupLocation: true,
								seller: {
									select: {
										id: true,
										displayName: true,
										avatarUrl: true,
									},
								},
							},
						},
					},
				},
			},
		});
	},

	async addItem(userId: string, payload: AddWishlistItemInput) {
		const listing = await prisma.listing.findUnique({
			where: { id: payload.listingId },
			select: {
				id: true,
				sellerId: true,
				status: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (listing.sellerId === userId) {
			throw new ApiError("You cannot add your own listing to the wishlist", 400);
		}

		if (listing.status !== ListingStatus.AVAILABLE) {
			throw new ApiError("Listing is not available", 400);
		}

		const wishlist = await getOrCreateWishlist(userId);

		const item = await prisma.wishlistItem.upsert({
			where: {
				wishlistId_listingId: {
					wishlistId: wishlist.id,
					listingId: payload.listingId,
				},
			},
			update: {
				quantity: 1,
			},
			create: {
				wishlistId: wishlist.id,
				listingId: payload.listingId,
				quantity: 1,
			},
			include: {
				listing: true,
			},
		});

		return item;
	},

	async removeItem(userId: string, listingId: string) {
		const wishlist = await getOrCreateWishlist(userId);

		await prisma.wishlistItem.deleteMany({
			where: {
				wishlistId: wishlist.id,
				listingId,
			},
		});
	},

	async clear(userId: string) {
		const wishlist = await getOrCreateWishlist(userId);

		await prisma.wishlistItem.deleteMany({
			where: { wishlistId: wishlist.id },
		});
	},
};
