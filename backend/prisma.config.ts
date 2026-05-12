import { resolve } from "node:path";

import dotenv from "dotenv";
import { defineConfig } from "prisma/config";

dotenv.config({ path: resolve(process.cwd(), ".env") });

const url =
	process.env.DATABASE_URL ?? "postgresql://postgres:postgres@localhost:5432/cedt_marketplace";

export default defineConfig({
	schema: "prisma/schema.prisma",
	migrations: {
		path: "prisma/migrations",
	},
	engine: "classic",
	datasource: {
		url: url,
	},
});
