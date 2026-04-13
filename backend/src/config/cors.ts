import { env } from "./env.js";

export const allowedOrigins = env.CORS_ORIGIN.split(",")
	.map((origin) => origin.trim())
	.filter(Boolean);
