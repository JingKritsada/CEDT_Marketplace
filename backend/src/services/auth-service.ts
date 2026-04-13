import bcrypt from "bcryptjs";

import { env } from "@/config/env.js";
import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { LoginInput } from "@/models/auth-model.js";
import { createAccessToken, createRefreshToken, verifyRefreshToken } from "@/utils/token.js";

interface AuthResult {
	accessToken: string;
	refreshToken: string;
	user: {
		id: string;
		email: string;
		displayName: string;
		studentId: string | null;
	};
}

const extractUsernameFromEmail = (email: string): string => {
	return email.split("@")[0];
};

const issueTokens = async (
	userId: string,
	email: string
): Promise<{ accessToken: string; refreshToken: string }> => {
	const payload = { sub: userId, email };
	const accessToken = createAccessToken(payload);
	const refreshToken = createRefreshToken(payload);
	const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

	await prisma.refreshToken.create({
		data: {
			userId,
			token: refreshToken,
			expiresAt,
		},
	});

	return { accessToken, refreshToken };
};

export const authService = {
	async login(input: LoginInput): Promise<AuthResult> {
		const existingUser = await prisma.user.findUnique({
			where: { email: input.email },
		});

		let user = existingUser;

		if (!user) {
			const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_SALT_ROUNDS);

			user = await prisma.user.create({
				data: {
					email: input.email,
					displayName: extractUsernameFromEmail(input.email),
					studentId: extractUsernameFromEmail(input.email),
					passwordHash,
				},
			});
		}

		const passwordMatches = await bcrypt.compare(input.password, user.passwordHash);

		if (!passwordMatches) {
			throw new ApiError("Invalid credentials", 401);
		}

		const tokens = await issueTokens(user.id, user.email);

		return {
			...tokens,
			user: {
				id: user.id,
				email: user.email,
				displayName: user.displayName,
				studentId: user.studentId,
			},
		};
	},

	async refresh(token: string): Promise<{ accessToken: string; refreshToken: string }> {
		const payload = verifyRefreshToken(token);

		const existingToken = await prisma.refreshToken.findUnique({
			where: { token },
		});

		if (!existingToken || existingToken.expiresAt.getTime() < Date.now()) {
			throw new ApiError("Refresh token is invalid or expired", 401);
		}

		const user = await prisma.user.findUnique({
			where: { id: payload.sub },
		});

		if (!user) {
			throw new ApiError("User not found", 404);
		}

		await prisma.refreshToken.delete({
			where: { token },
		});

		return issueTokens(user.id, user.email);
	},
};
