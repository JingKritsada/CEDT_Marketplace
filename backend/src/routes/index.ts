import { Router } from "express";

import { authRouter } from "./auth-route";
import { categoryRouter } from "./category-route";
import { listingRouter } from "./listing-route";
import { pickupLocationRouter } from "./pickup-location-route";
import { userRouter } from "./user-route";

export const apiRouter = Router();

apiRouter.use("/auth", authRouter);
apiRouter.use("/listings", listingRouter);
apiRouter.use("/categories", categoryRouter);
apiRouter.use("/pickup-locations", pickupLocationRouter);
apiRouter.use("/users", userRouter);
