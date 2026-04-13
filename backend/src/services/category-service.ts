import { prisma } from "@/config/prisma.js";

export const categoryService = {
	async getAll() {
		return prisma.category.findMany({
			orderBy: {
				name: "asc",
			},
		});
	},
};
