import type { CreateCategoryInput } from "@/models/category-model.js";
import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";

let cachedCategories: Awaited<ReturnType<typeof prisma.category.findMany>> | null = null;
let cacheLoadedAt: number | null = null;
const cacheTtlMs = 10 * 60 * 1000;

const clearCategoryCache = () => {
	cachedCategories = null;
	cacheLoadedAt = null;
};

export const categoryService = {
	async getAll() {
		if (cachedCategories && cacheLoadedAt && Date.now() - cacheLoadedAt < cacheTtlMs) {
			return cachedCategories;
		}

		const categories = await prisma.category.findMany({
			orderBy: {
				name: "asc",
			},
		});

		cachedCategories = categories;
		cacheLoadedAt = Date.now();

		return categories;
	},

	async create(payload: CreateCategoryInput) {
		const existingCategory = await prisma.category.findUnique({
			where: { slug: payload.slug },
			select: { id: true },
		});

		if (existingCategory) {
			throw new ApiError("Category slug already exists", 400);
		}

		const category = await prisma.category.create({
			data: payload,
		});

		clearCategoryCache();

		return category;
	},
};
