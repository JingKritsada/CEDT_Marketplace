import crypto from "node:crypto";
import type { Request, Response } from "express";
import jwt from "jsonwebtoken";
import jwksClient from "jwks-rsa";

import { env } from "@/config/env.js";
import { asyncHandler } from "@/utils/async-handler.js";
import { ApiError } from "@/utils/api-error.js";
import { authService } from "@/services/auth-service.js";
import { ok } from "@/utils/api-response.js";

const STATE_TTL_SECONDS = 600;

interface OAuthState {
	nonce: string;
	provider: "google" | "facebook";
}

const facebookRedirectUri = (): string => `${env.OAUTH_CALLBACK_BASE}/auth/oauth/facebook/callback`;

const signState = (provider: OAuthState["provider"]): string => {
	const payload: OAuthState = { nonce: crypto.randomBytes(16).toString("hex"), provider };
	return jwt.sign(payload, env.JWT_SECRET, { expiresIn: STATE_TTL_SECONDS });
};

const verifyState = (token: string, expected: OAuthState["provider"]): void => {
	const decoded = jwt.verify(token, env.JWT_SECRET) as OAuthState;
	if (decoded.provider !== expected) {
		throw new ApiError("State mismatch", 400);
	}
};

const googleRedirectUri = (): string => `${env.OAUTH_CALLBACK_BASE}/auth/oauth/google/callback`;

const buildMobileRedirect = (params: {
	accessToken?: string;
	refreshToken?: string;
	error?: string;
}): string => {
	const url = new URL(env.MOBILE_OAUTH_REDIRECT);
	const fragment = new URLSearchParams();
	if (params.accessToken) fragment.set("access", params.accessToken);
	if (params.refreshToken) fragment.set("refresh", params.refreshToken);
	if (params.error) fragment.set("error", params.error);
	url.hash = fragment.toString();
	return url.toString();
};

export const googleStart = asyncHandler(async (_req: Request, res: Response) => {
	if (!env.GOOGLE_CLIENT_ID) {
		throw new ApiError("Google OAuth is not configured", 500);
	}

	const state = signState("google");
	const params = new URLSearchParams({
		client_id: env.GOOGLE_CLIENT_ID,
		redirect_uri: googleRedirectUri(),
		response_type: "code",
		scope: "openid email profile",
		access_type: "offline",
		prompt: "select_account",
		state,
	});

	res.redirect(`https://accounts.google.com/o/oauth2/v2/auth?${params.toString()}`);
});

interface GoogleTokenResponse {
	access_token: string;
	id_token: string;
	expires_in: number;
	token_type: string;
}

interface GoogleUserInfo {
	sub: string;
	email?: string;
	email_verified?: boolean;
	name?: string;
	given_name?: string;
	picture?: string;
}

export const googleCallback = asyncHandler(async (req: Request, res: Response) => {
	const { code, state, error: providerError } = req.query as Record<string, string | undefined>;

	if (providerError) {
		return res.redirect(buildMobileRedirect({ error: providerError }));
	}
	if (!code || !state) {
		return res.redirect(buildMobileRedirect({ error: "missing_code_or_state" }));
	}

	try {
		verifyState(state, "google");
	} catch {
		return res.redirect(buildMobileRedirect({ error: "invalid_state" }));
	}

	if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) {
		return res.redirect(buildMobileRedirect({ error: "oauth_not_configured" }));
	}

	const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
		method: "POST",
		headers: { "Content-Type": "application/x-www-form-urlencoded" },
		body: new URLSearchParams({
			code,
			client_id: env.GOOGLE_CLIENT_ID,
			client_secret: env.GOOGLE_CLIENT_SECRET,
			redirect_uri: googleRedirectUri(),
			grant_type: "authorization_code",
		}).toString(),
	});

	if (!tokenRes.ok) {
		return res.redirect(buildMobileRedirect({ error: "token_exchange_failed" }));
	}

	const tokens = (await tokenRes.json()) as GoogleTokenResponse;

	const userInfoRes = await fetch("https://openidconnect.googleapis.com/v1/userinfo", {
		headers: { Authorization: `Bearer ${tokens.access_token}` },
	});

	if (!userInfoRes.ok) {
		return res.redirect(buildMobileRedirect({ error: "userinfo_failed" }));
	}

	const profile = (await userInfoRes.json()) as GoogleUserInfo;

	const result = await authService.socialLogin({
		provider: "GOOGLE",
		providerUserId: profile.sub,
		email: profile.email ?? null,
		displayName: profile.name ?? profile.given_name ?? profile.email ?? "Google User",
		avatarUrl: profile.picture ?? null,
	});

	return res.redirect(
		buildMobileRedirect({
			accessToken: result.accessToken,
			refreshToken: result.refreshToken,
		})
	);
});

export const facebookStart = asyncHandler(async (_req: Request, res: Response) => {
	if (!env.FACEBOOK_APP_ID) {
		throw new ApiError("Facebook OAuth is not configured", 500);
	}

	const state = signState("facebook");
	const params = new URLSearchParams({
		client_id: env.FACEBOOK_APP_ID,
		redirect_uri: facebookRedirectUri(),
		response_type: "code",
		scope: "email,public_profile",
		state,
	});

	res.redirect(`https://www.facebook.com/v18.0/dialog/oauth?${params.toString()}`);
});

interface FacebookTokenResponse {
	access_token: string;
	token_type: string;
	expires_in: number;
}

interface FacebookUserInfo {
	id: string;
	email?: string;
	name?: string;
	picture?: { data: { url: string } };
}

export const facebookCallback = asyncHandler(async (req: Request, res: Response) => {
	const { code, state, error: providerError } = req.query as Record<string, string | undefined>;

	if (providerError) {
		return res.redirect(buildMobileRedirect({ error: providerError }));
	}
	if (!code || !state) {
		return res.redirect(buildMobileRedirect({ error: "missing_code_or_state" }));
	}

	try {
		verifyState(state, "facebook");
	} catch {
		return res.redirect(buildMobileRedirect({ error: "invalid_state" }));
	}

	if (!env.FACEBOOK_APP_ID || !env.FACEBOOK_APP_SECRET) {
		return res.redirect(buildMobileRedirect({ error: "oauth_not_configured" }));
	}

	const tokenUrl = new URL("https://graph.facebook.com/v18.0/oauth/access_token");
	tokenUrl.searchParams.set("client_id", env.FACEBOOK_APP_ID);
	tokenUrl.searchParams.set("client_secret", env.FACEBOOK_APP_SECRET);
	tokenUrl.searchParams.set("redirect_uri", facebookRedirectUri());
	tokenUrl.searchParams.set("code", code);

	const tokenRes = await fetch(tokenUrl);
	if (!tokenRes.ok) {
		return res.redirect(buildMobileRedirect({ error: "token_exchange_failed" }));
	}
	const tokens = (await tokenRes.json()) as FacebookTokenResponse;

	const userInfoUrl = new URL("https://graph.facebook.com/v18.0/me");
	userInfoUrl.searchParams.set("fields", "id,name,email,picture");
	userInfoUrl.searchParams.set("access_token", tokens.access_token);

	const userInfoRes = await fetch(userInfoUrl);
	if (!userInfoRes.ok) {
		return res.redirect(buildMobileRedirect({ error: "userinfo_failed" }));
	}
	const profile = (await userInfoRes.json()) as FacebookUserInfo;

	const result = await authService.socialLogin({
		provider: "FACEBOOK",
		providerUserId: profile.id,
		email: profile.email ?? null,
		displayName: profile.name ?? profile.email ?? "Facebook User",
		avatarUrl: profile.picture?.data?.url ?? null,
	});

	return res.redirect(
		buildMobileRedirect({
			accessToken: result.accessToken,
			refreshToken: result.refreshToken,
		})
	);
});

const appleJwks = jwksClient({
	jwksUri: "https://appleid.apple.com/auth/keys",
	cache: true,
	cacheMaxAge: 24 * 60 * 60 * 1000,
});

const getApplePublicKey = (kid: string): Promise<string> =>
	new Promise((resolve, reject) => {
		appleJwks.getSigningKey(kid, (err, key) => {
			if (err || !key) return reject(err ?? new Error("Apple key not found"));
			resolve(key.getPublicKey());
		});
	});

interface AppleIdTokenPayload {
	iss: string;
	aud: string;
	sub: string;
	email?: string;
	email_verified?: boolean | string;
	exp: number;
}

export const appleNativeLogin = asyncHandler(async (req: Request, res: Response) => {
	const { identityToken, fullName } = req.body as {
		identityToken?: string;
		fullName?: { givenName?: string; familyName?: string };
	};

	if (!identityToken) {
		throw new ApiError("identityToken is required", 400);
	}

	const decoded = jwt.decode(identityToken, { complete: true });
	if (!decoded || typeof decoded === "string" || !decoded.header.kid) {
		throw new ApiError("Invalid Apple identity token", 400);
	}

	const publicKey = await getApplePublicKey(decoded.header.kid);

	let payload: AppleIdTokenPayload;
	try {
		payload = jwt.verify(identityToken, publicKey, {
			algorithms: ["RS256"],
			issuer: "https://appleid.apple.com",
			audience: env.APPLE_BUNDLE_ID,
		}) as AppleIdTokenPayload;
	} catch {
		throw new ApiError("Apple token verification failed", 401);
	}

	const displayName =
		[fullName?.givenName, fullName?.familyName].filter(Boolean).join(" ").trim() ||
		payload.email ||
		"Apple User";

	const result = await authService.socialLogin({
		provider: "APPLE",
		providerUserId: payload.sub,
		email: payload.email ?? null,
		displayName,
	});

	res.status(200).json(ok(result));
});
