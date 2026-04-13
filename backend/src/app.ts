import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";

import { allowedOrigins } from "./config/cors";
import { errorHandler } from "./middlewares/error-handler";
import { notFoundHandler } from "./middlewares/not-found";
import { apiRouter } from "./routes";

export const app = express();

app.use(helmet());
app.use(
	cors({
		origin: allowedOrigins,
	})
);
app.use(express.json({ limit: "2mb" }));
app.use(morgan("dev"));

app.get("/health", (_req, res) => {
	res.status(200).json({
		status: "ok",
	});
});

app.use(apiRouter);
app.use(notFoundHandler);
app.use(errorHandler);
