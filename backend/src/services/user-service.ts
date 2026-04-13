import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";

export const userService = {
	async getById(id: string) {
		const user = await prisma.user.findUnique({
			where: { id },
			include: {
				listings: {
					orderBy: {
						createdAt: "desc",
					},
				},
			},
		});

		if (!user) {
			throw new ApiError("User not found", 404);
		}

		return {
			id: user.id,
			email: user.email,
			displayName: user.displayName,
			studentId: user.studentId,
			avatarUrl: user.avatarUrl,
			createdAt: user.createdAt,
			listings: user.listings,
		};
	},
};
