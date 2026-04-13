import { Router } from "express";

import { login, refresh } from "../controllers/auth-controller";
import { loginSchema, refreshTokenSchema } from "../models/auth-model";
import { authRateLimit } from "../middlewares/rate-limit";
import { validate } from "../middlewares/validate";

export const authRouter = Router();

authRouter.post("/login", authRateLimit, validate(loginSchema), login);
authRouter.post("/refresh", authRateLimit, validate(refreshTokenSchema), refresh);
