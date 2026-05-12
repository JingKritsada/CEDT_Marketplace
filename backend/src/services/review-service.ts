import { ListingStatus } from "@prisma/client";

import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { CreateReviewInput, ReviewQueryInput } from "@/models/review-model.js";

export const reviewService = {
	async list(query: ReviewQueryInput) {
		if (!query.listingId && !query.sellerId) {
			throw new ApiError("listingId or sellerId is required", 400);
		}

		return prisma.review.findMany({
			where: {
				listingId: query.listingId,
				sellerId: query.sellerId,
			},
			include: {
				reviewer: {
					select: {
						id: true,
						displayName: true,
						avatarUrl: true,
					},
				},
			},
			orderBy: {
				createdAt: "desc",
			},
		});
	},

	async create(userId: string, payload: CreateReviewInput) {
		const listing = await prisma.listing.findUnique({
			where: { id: payload.listingId },
			select: {
				id: true,
				sellerId: true,
				buyerId: true,
				status: true,
			},
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (listing.sellerId === userId) {
			throw new ApiError("Sellers cannot review their own listing", 400);
		}

		if (listing.buyerId && listing.buyerId !== userId) {
			throw new ApiError("Only the buyer can review this listing", 403);
		}

		if (listing.status !== ListingStatus.RECEIVED && listing.status !== ListingStatus.RATED) {
			throw new ApiError("Listing is not eligible for review", 400);
		}

		const review = await prisma.review.create({
			data: {
				listingId: listing.id,
				sellerId: listing.sellerId,
				reviewerId: userId,
				rating: payload.rating,
				comment: payload.comment,
			},
			include: {
				reviewer: {
					select: {
						id: true,
						displayName: true,
						avatarUrl: true,
					},
				},
			},
		});

		if (listing.status !== ListingStatus.RATED) {
			await prisma.listing.update({
				where: { id: listing.id },
				data: { status: ListingStatus.RATED },
			});
		}

		return review;
	},
};
