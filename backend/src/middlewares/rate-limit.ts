import rateLimit from "express-rate-limit";

export const authRateLimit = rateLimit({
	windowMs: 15 * 60 * 1000,
	limit: 20,
	standardHeaders: true,
	legacyHeaders: false,
});

export const userRateLimit = rateLimit({
	windowMs: 15 * 60 * 1000,
	limit: 120,
	standardHeaders: true,
	legacyHeaders: false,
});

export const writeRateLimit = rateLimit({
	windowMs: 15 * 60 * 1000,
	limit: 60,
	standardHeaders: true,
	legacyHeaders: false,
});
