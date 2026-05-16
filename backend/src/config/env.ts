import { z } from "zod";
import dotenv from "dotenv";

dotenv.config();

const envSchema = z.object({
	NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
	PORT: z.coerce.number().int().positive().default(3003),
	CORS_ORIGIN: z.string().default("http://localhost:3003"),
	BCRYPT_SALT_ROUNDS: z.coerce.number().int().min(10).max(15).default(12),
	STUDENT_EMAIL_DOMAIN: z.string().default("student.chula.ac.th"),
	JWT_SECRET: z.string().min(32).optional(),
	JWT_REFRESH_SECRET: z.string().min(32).optional(),
	STRIPE_SECRET_KEY: z.string().optional(),
	STRIPE_PUBLISHABLE_KEY: z.string().optional(),
	STRIPE_WEBHOOK_SECRET: z.string().optional(),
	STRIPE_API_VERSION: z.string().optional(),
	STRIPE_CONNECT_RETURN_URL: z.string().default("cedtmkt://stripe/return"),
	STRIPE_CONNECT_REFRESH_URL: z.string().default("cedtmkt://stripe/refresh"),
	PLATFORM_FEE_BPS: z.coerce.number().int().min(0).max(10000).default(500),
	PAYMENT_AUTH_EXPIRE_HOURS: z.coerce.number().int().min(1).default(144),
	OAUTH_CALLBACK_BASE: z.string().url().default("http://localhost:3003"),
	MOBILE_OAUTH_REDIRECT: z.string().default("cedtmkt://auth/callback"),
	GOOGLE_CLIENT_ID: z.string().optional(),
	GOOGLE_CLIENT_SECRET: z.string().optional(),
	FACEBOOK_APP_ID: z.string().optional(),
	FACEBOOK_APP_SECRET: z.string().optional(),
	APPLE_SERVICES_ID: z.string().optional(),
	APPLE_TEAM_ID: z.string().optional(),
	APPLE_KEY_ID: z.string().optional(),
	APPLE_PRIVATE_KEY: z.string().optional(),
	APPLE_BUNDLE_ID: z.string().default("com.jing.CEDT-Marketplace"),
});

const parsedEnv = envSchema.parse(process.env);

if (
	parsedEnv.NODE_ENV === "production" &&
	(!parsedEnv.JWT_SECRET || !parsedEnv.JWT_REFRESH_SECRET)
) {
	throw new Error("JWT_SECRET and JWT_REFRESH_SECRET are required in production.");
}

if (
	parsedEnv.NODE_ENV === "production" &&
	(!parsedEnv.STRIPE_SECRET_KEY || !parsedEnv.STRIPE_WEBHOOK_SECRET)
) {
	throw new Error("STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET are required in production.");
}

export const env = {
	...parsedEnv,
	JWT_SECRET: parsedEnv.JWT_SECRET ?? "development-access-secret-change-me-1234",
	JWT_REFRESH_SECRET: parsedEnv.JWT_REFRESH_SECRET ?? "development-refresh-secret-change-me-1234",
};
