import { prisma } from "../config/prisma";

export const categoryService = {
	async getAll() {
		return prisma.category.findMany({
			orderBy: {
				name: "asc",
			},
		});
	},
};
