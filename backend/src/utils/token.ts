import jwt from "jsonwebtoken";

import { env } from "../config/env";

export interface AuthTokenPayload {
	sub: string;
	email: string;
}

export const createAccessToken = (payload: AuthTokenPayload): string => {
	return jwt.sign(payload, env.JWT_SECRET, { expiresIn: "15m" });
};

export const createRefreshToken = (payload: AuthTokenPayload): string => {
	return jwt.sign(payload, env.JWT_REFRESH_SECRET, { expiresIn: "7d" });
};

export const verifyAccessToken = (token: string): AuthTokenPayload => {
	return jwt.verify(token, env.JWT_SECRET) as AuthTokenPayload;
};

export const verifyRefreshToken = (token: string): AuthTokenPayload => {
	return jwt.verify(token, env.JWT_REFRESH_SECRET) as AuthTokenPayload;
};
