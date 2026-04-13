import { Router } from "express";

import { login, refresh } from "../controllers/auth-controller";
import { loginSchema, refreshTokenSchema } from "../models/auth-model";
import { validate } from "../middlewares/validate";

export const authRouter = Router();

authRouter.post("/login", validate(loginSchema), login);
authRouter.post("/refresh", validate(refreshTokenSchema), refresh);
