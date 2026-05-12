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
});

const parsedEnv = envSchema.parse(process.env);

if (
	parsedEnv.NODE_ENV === "production" &&
	(!parsedEnv.JWT_SECRET || !parsedEnv.JWT_REFRESH_SECRET)
) {
	throw new Error("JWT_SECRET and JWT_REFRESH_SECRET are required in production.");
}

export const env = {
	...parsedEnv,
	JWT_SECRET: parsedEnv.JWT_SECRET ?? "development-access-secret-change-me-1234",
	JWT_REFRESH_SECRET: parsedEnv.JWT_REFRESH_SECRET ?? "development-refresh-secret-change-me-1234",
};
