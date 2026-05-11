import bcrypt from "bcryptjs";

import { env } from "@/config/env.js";
import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { LoginInput, RegisterInput } from "@/models/auth-model.js";
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

const allowedEmailDomains = env.ALLOWED_EMAIL_DOMAINS.split(",")
	.map((domain) => domain.trim().replace(/^@/, "").toLowerCase())
	.filter(Boolean);

const ensureAllowedEmail = (email: string): void => {
	if (allowedEmailDomains.length === 0) {
		return;
	}

	const normalizedEmail = email.toLowerCase();
	const isAllowed = allowedEmailDomains.some((domain) => normalizedEmail.endsWith(`@${domain}`));

	if (!isAllowed) {
		throw new ApiError("Email domain is not allowed", 400);
	}
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
	async register(input: RegisterInput): Promise<AuthResult> {
		ensureAllowedEmail(input.email);
		const existingUser = await prisma.user.findUnique({
			where: { email: input.email },
		});

		if (existingUser) {
			throw new ApiError("Email already registered", 400);
		}

		const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_SALT_ROUNDS);

		const user = await prisma.user.create({
			data: {
				studentId: input.studentId,
				email: input.email,
				displayName: input.displayName,
				passwordHash,
			},
		});

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

	async login(input: LoginInput): Promise<AuthResult> {
		ensureAllowedEmail(input.email);
		const existingUser = await prisma.user.findUnique({
			where: { email: input.email },
		});

		if (!existingUser) {
			throw new ApiError("Invalid credentials", 401);
		}

		const passwordMatches = await bcrypt.compare(input.password, existingUser.passwordHash);

		if (!passwordMatches) {
			throw new ApiError("Invalid credentials", 401);
		}

		const tokens = await issueTokens(existingUser.id, existingUser.email);

		return {
			...tokens,
			user: {
				id: existingUser.id,
				email: existingUser.email,
				displayName: existingUser.displayName,
				studentId: existingUser.studentId,
			},
		};
	},

	async refresh(token: string): Promise<{ accessToken: string; refreshToken: string }> {
		let payload: { sub: string; email: string };

		try {
			payload = verifyRefreshToken(token);
		} catch {
			throw new ApiError("Refresh token is invalid or expired", 401);
		}

		const existingToken = await prisma.refreshToken.findUnique({
			where: { token },
		});

		if (!existingToken || existingToken.expiresAt.getTime() < Date.now()) {
			if (existingToken) {
				await prisma.refreshToken.delete({
					where: { token },
				});
			}
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

	async logout(token: string): Promise<void> {
		await prisma.refreshToken.deleteMany({
			where: { token },
		});
	},
};
