import { ListingStatus } from "@prisma/client";

import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { AddCartItemInput } from "@/models/cart-model.js";

const getOrCreateCart = async (userId: string) => {
	return prisma.cart.upsert({
		where: { userId },
		update: {},
		create: { userId },
	});
};

export const cartService = {
	async getCart(userId: string) {
		const cart = await getOrCreateCart(userId);

		return prisma.cart.findUnique({
			where: { id: cart.id },
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

	async addItem(userId: string, payload: AddCartItemInput) {
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
			throw new ApiError("You cannot add your own listing to the cart", 400);
		}

		if (listing.status !== ListingStatus.AVAILABLE) {
			throw new ApiError("Listing is not available", 400);
		}

		const cart = await getOrCreateCart(userId);

		const item = await prisma.cartItem.upsert({
			where: {
				cartId_listingId: {
					cartId: cart.id,
					listingId: payload.listingId,
				},
			},
			update: {
				quantity: 1,
			},
			create: {
				cartId: cart.id,
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
		const cart = await getOrCreateCart(userId);

		await prisma.cartItem.deleteMany({
			where: {
				cartId: cart.id,
				listingId,
			},
		});
	},

	async clear(userId: string) {
		const cart = await getOrCreateCart(userId);

		await prisma.cartItem.deleteMany({
			where: { cartId: cart.id },
		});
	},
};
