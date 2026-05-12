import { Router } from "express";

import { userRouter } from "./user-route.js";
import { authRouter } from "./auth-route.js";
import { listingRouter } from "./listing-route.js";
import { categoryRouter } from "./category-route.js";
import { pickupLocationRouter } from "./pickup-location-route.js";
import { cartRouter } from "./cart-route.js";
import { reviewRouter } from "./review-route.js";
import { chatRouter } from "./chat-route.js";

export const apiRouter = Router();

apiRouter.use("/auth", authRouter);
apiRouter.use("/listings", listingRouter);
apiRouter.use("/categories", categoryRouter);
apiRouter.use("/pickup-locations", pickupLocationRouter);
apiRouter.use("/users", userRouter);
apiRouter.use("/cart", cartRouter);
apiRouter.use("/reviews", reviewRouter);
apiRouter.use("/chat", chatRouter);
