import { Router } from "express";

import { getMe } from "../controllers/user-controller";
import { requireAuth } from "../middlewares/auth";
import { userRateLimit } from "../middlewares/rate-limit";

export const userRouter = Router();

userRouter.get("/me", userRateLimit, requireAuth, getMe);
