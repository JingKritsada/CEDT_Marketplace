import { Router } from "express";

import { getMe } from "../controllers/user-controller";
import { requireAuth } from "../middlewares/auth";

export const userRouter = Router();

userRouter.get("/me", requireAuth, getMe);
