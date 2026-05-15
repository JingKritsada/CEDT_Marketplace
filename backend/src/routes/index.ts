import { Router } from "express";

import { userRouter } from "./user-route.js";
import { authRouter } from "./auth-route.js";
import { listingRouter } from "./listing-route.js";
import { categoryRouter } from "./category-route.js";
import { pickupLocationRouter } from "./pickup-location-route.js";
import { wishlistRouter } from "./wishlist-route.js";
import { reviewRouter } from "./review-route.js";
import { uploadRouter } from "./upload-route.js";
import { sellerOnboardingRouter } from "./seller-onboarding-route.js";
import { checkoutRouter, paymentRouter } from "./payment-route.js";

export const apiRouter = Router();

apiRouter.use("/auth", authRouter);
apiRouter.use("/listings", listingRouter);
apiRouter.use("/categories", categoryRouter);
apiRouter.use("/pickup-locations", pickupLocationRouter);
apiRouter.use("/users", userRouter);
apiRouter.use("/wishlist", wishlistRouter);
apiRouter.use("/reviews", reviewRouter);
apiRouter.use("/uploads", uploadRouter);
apiRouter.use("/sellers", sellerOnboardingRouter);
apiRouter.use("/payments", paymentRouter);
apiRouter.use("/checkout", checkoutRouter);
