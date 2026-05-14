import { createServer } from "node:http";

import { app } from "./app.js";
import { env } from "./config/env.js";

const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";
const CYAN = "\x1b[36m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const DIM = "\x1b[2m";

function log(label: string, value: string, labelColor = CYAN) {
	const pad = "  ";

	console.log(`${pad}${labelColor}${BOLD}${label.padEnd(14)}${RESET}  ${value}`);
}

const server = createServer(app);

server.listen(env.PORT, () => {
	const divider = `${DIM}${"─".repeat(48)}${RESET}`;

	console.log("");
	console.log(`  ${GREEN}${BOLD}▶  Server Ready${RESET}`);

	console.log(divider);

	log("Port", `${GREEN}${env.PORT}${RESET}`);
	log(
		"Environment",
		env.NODE_ENV === "production"
			? `${RED}${env.NODE_ENV}${RESET}`
			: `${YELLOW}${env.NODE_ENV}${RESET}`
	);
	log("Local", `${CYAN}http://localhost:${env.PORT}${RESET}`);
	log("Health", `${DIM}http://localhost:${env.PORT}/health${RESET}`);
	log("Docs", `${DIM}http://localhost:${env.PORT}/api-docs${RESET}`);
	log("Started at", `${DIM}${new Date().toLocaleString("en-GB")}${RESET}`);

	console.log(divider);

	console.log("");
	console.log(
		`  ${DIM}TIME    METHOD   URL                                            STATUS   DURATION     SIZE${RESET}`
	);
	console.log(`  ${DIM}${"─".repeat(96)}${RESET}`);
});

const shutdown = (signal: string) => {
	console.log("");
	console.log(`  ${YELLOW}${BOLD}⏹  ${signal} received — shutting down gracefully…${RESET}`);

	server.close(() => {
		console.log(`  ${GREEN}✓  Server closed${RESET}`);
		process.exit(0);
	});

	setTimeout(() => {
		console.error(`  ${RED}✗  Forced exit after timeout${RESET}`);
		process.exit(1);
	}, 10_000);
};

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
