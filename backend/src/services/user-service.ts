import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { UpdateUserProfileInput } from "@/models/user-model.js";

export const userService = {
	async getById(id: string) {
		const user = await prisma.user.findUnique({
			where: { id },
			include: {
				listings: {
					orderBy: { createdAt: "desc" },
				},
				buyerListings: {
					orderBy: { createdAt: "desc" },
				},
			},
		});

		if (!user) {
			throw new ApiError("User not found", 404);
		}

		const ratingSummary = await prisma.review.aggregate({
			where: { sellerId: user.id },
			_avg: { rating: true },
			_count: { rating: true },
		});

		// Merge seller-side and buyer-side listings (deduped). The frontend filters
		// this combined list by sellerId / buyerId to populate Posted / Purchased /
		// Sold / Confirmed views, so it needs to see both sides.
		const seen = new Set<string>();
		const merged: typeof user.listings = [];
		for (const listing of [...user.listings, ...user.buyerListings]) {
			if (seen.has(listing.id)) continue;
			seen.add(listing.id);
			merged.push(listing);
		}
		merged.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

		return {
			id: user.id,
			email: user.email,
			displayName: user.displayName,
			studentId: user.studentId,
			avatarUrl: user.avatarUrl,
			lineId: user.lineId,
			instagram: user.instagram,
			facebookUrl: user.facebookUrl,
			createdAt: user.createdAt,
			listings: merged,
			rating: {
				average: ratingSummary._avg.rating ?? 0,
				count: ratingSummary._count.rating,
			},
		};
	},

	async updateProfile(id: string, payload: UpdateUserProfileInput) {
		const user = await prisma.user.update({
			where: { id },
			data: payload,
			select: {
				id: true,
				email: true,
				displayName: true,
				studentId: true,
				avatarUrl: true,
				lineId: true,
				instagram: true,
				facebookUrl: true,
				createdAt: true,
			},
		});

		return user;
	},
};
