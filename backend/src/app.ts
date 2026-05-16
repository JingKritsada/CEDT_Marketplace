import path from "node:path";

import cors from "cors";
import helmet from "helmet";
import express from "express";

// Allow BigInt fields (e.g. SellerProfile.totalEarnedSatang) to be JSON-serialized.
// Serialize as a string to preserve precision; clients can parse with Number()/BigInt().
(BigInt.prototype as unknown as { toJSON: () => string }).toJSON = function () {
	return this.toString();
};

import { apiRouter } from "./routes/index.js";
import { webhookRouter } from "./routes/webhook-route.js";
import { allowedOrigins } from "./config/cors.js";
import { setupSwagger } from "./config/swagger.js";
import { errorHandler } from "./middlewares/error-handler.js";
import { notFoundHandler } from "./middlewares/not-found.js";
import { httpLogger } from "./middlewares/logger.js";
import { ok } from "./utils/api-response.js";

export const app = express();

setupSwagger(app);

app.use(helmet());
app.use(
	cors({
		origin: allowedOrigins,
	})
);

// Stripe webhooks MUST receive the raw request body to verify the signature.
// Mount this BEFORE express.json() so the raw body is preserved.
app.use("/webhooks", webhookRouter);

app.use(express.json({ limit: "2mb" }));
app.use(express.static(path.join(process.cwd(), "public")));
app.use(httpLogger);

app.get("/health", (_req, res) => {
	res.status(200).json(ok({ status: "ok" }));
});

app.use(apiRouter);
app.use(notFoundHandler);
app.use(errorHandler);
