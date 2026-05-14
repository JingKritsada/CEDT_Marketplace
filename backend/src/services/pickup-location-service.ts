import type { CreatePickupLocationInput } from "@/models/pickup-location-model.js";
import { prisma } from "@/config/prisma.js";

let cachedPickupLocations: Awaited<ReturnType<typeof prisma.pickupLocation.findMany>> | null = null;
let cacheLoadedAt: number | null = null;
const cacheTtlMs = 10 * 60 * 1000;

const clearPickupLocationCache = () => {
	cachedPickupLocations = null;
	cacheLoadedAt = null;
};

export const pickupLocationService = {
	async getAll() {
		if (cachedPickupLocations && cacheLoadedAt && Date.now() - cacheLoadedAt < cacheTtlMs) {
			return cachedPickupLocations;
		}

		const pickupLocations = await prisma.pickupLocation.findMany({
			orderBy: {
				name: "asc",
			},
		});

		cachedPickupLocations = pickupLocations;
		cacheLoadedAt = Date.now();

		return pickupLocations;
	},

	async create(payload: CreatePickupLocationInput) {
		const pickupLocation = await prisma.pickupLocation.create({
			data: payload,
		});

		clearPickupLocationCache();

		return pickupLocation;
	},
};
