import { prisma } from "@/config/prisma.js";

export const pickupLocationService = {
	async getAll() {
		return prisma.pickupLocation.findMany({
			orderBy: {
				name: "asc",
			},
		});
	},
};
