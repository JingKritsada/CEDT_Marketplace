import bcrypt from "bcryptjs";
import type { AuthProvider } from "@prisma/client";

import { env } from "@/config/env.js";
import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { LoginInput, RegisterInput } from "@/models/auth-model.js";
import { createAccessToken, createRefreshToken, verifyRefreshToken } from "@/utils/token.js";

export interface SocialProfile {
	provider: AuthProvider;
	providerUserId: string;
	email: string | null;
	displayName: string;
	avatarUrl?: string | null;
}

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

const isStudentEmail = (email: string): boolean => {
	return email.toLowerCase().endsWith(`@${env.STUDENT_EMAIL_DOMAIN.toLowerCase()}`);
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
				studentVerified: isStudentEmail(input.email),
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
		const existingUser = await prisma.user.findUnique({
			where: { email: input.email },
		});

		if (!existingUser || !existingUser.passwordHash) {
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

	async logout(token: string): Promise<void> {
		await prisma.refreshToken.deleteMany({
			where: { token },
		});
	},

	async socialLogin(profile: SocialProfile): Promise<AuthResult> {
		const { provider, providerUserId, email, displayName, avatarUrl } = profile;

		const identity = await prisma.userIdentity.findUnique({
			where: { provider_providerUserId: { provider, providerUserId } },
			include: { user: true },
		});

		let user = identity?.user ?? null;

		if (!user && email) {
			user = await prisma.user.findUnique({ where: { email } });
			if (user) {
				await prisma.userIdentity.create({
					data: { userId: user.id, provider, providerUserId, email },
				});
			}
		}

		if (!user) {
			const fallbackEmail =
				email ?? `${provider.toLowerCase()}_${providerUserId}@users.noreply.cedtmkt`;
			user = await prisma.user.create({
				data: {
					email: fallbackEmail,
					displayName,
					avatarUrl: avatarUrl ?? null,
					studentVerified: !!email && isStudentEmail(email),
					identities: {
						create: { provider, providerUserId, email },
					},
				},
			});
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
};
