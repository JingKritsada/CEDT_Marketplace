import { prisma } from "../config/prisma";

export const pickupLocationService = {
	async getAll() {
		return prisma.pickupLocation.findMany({
			orderBy: {
				name: "asc",
			},
		});
	},
};
