import path from "node:path";

import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import express from "express";

import { apiRouter } from "./routes/index.js";
import { allowedOrigins } from "./config/cors.js";
import { setupSwagger } from "./config/swagger.js";
import { errorHandler } from "./middlewares/error-handler.js";
import { notFoundHandler } from "./middlewares/not-found.js";

export const app = express();

setupSwagger(app);

app.use(helmet());
app.use(
	cors({
		origin: allowedOrigins,
	})
);
app.use(express.json({ limit: "2mb" }));
app.use(express.static(path.join(process.cwd(), "public")));
app.use(morgan("dev"));

app.get("/health", (_req, res) => {
	res.status(200).json({
		status: "ok",
	});
});

app.use(apiRouter);
app.use(notFoundHandler);
app.use(errorHandler);
