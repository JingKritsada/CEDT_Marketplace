import bcrypt from "bcryptjs";

import { prisma } from "../config/prisma";
import type { LoginInput } from "../models/auth-model";
import { ApiError } from "../utils/api-error";
import { createAccessToken, createRefreshToken, verifyRefreshToken } from "../utils/token";

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

const buildStudentId = (email: string): string => {
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
			const passwordHash = await bcrypt.hash(input.password, 12);

			user = await prisma.user.create({
				data: {
					email: input.email,
					displayName: buildStudentId(input.email),
					studentId: buildStudentId(input.email),
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

	async refresh(token: string): Promise<{ accessToken: string }> {
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

		return {
			accessToken: createAccessToken({ sub: user.id, email: user.email }),
		};
	},
};
