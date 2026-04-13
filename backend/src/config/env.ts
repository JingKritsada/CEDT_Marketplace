import dotenv from "dotenv";
import { z } from "zod";

dotenv.config();

const envSchema = z.object({
	NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
	PORT: z.coerce.number().int().positive().default(3000),
	JWT_SECRET: z.string().min(8).default("development-access-secret"),
	JWT_REFRESH_SECRET: z.string().min(8).default("development-refresh-secret"),
});

export const env = envSchema.parse(process.env);
