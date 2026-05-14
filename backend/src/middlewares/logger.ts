import morgan from "morgan";

const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";
const DIM = "\x1b[2m";

const METHOD_COLOR: Record<string, string> = {
	GET: "\x1b[36m", // cyan
	POST: "\x1b[32m", // green
	PUT: "\x1b[33m", // yellow
	PATCH: "\x1b[33m", // yellow
	DELETE: "\x1b[31m", // red
};

function statusColor(status: number): string {
	if (status >= 500) return "\x1b[31m"; // red
	if (status >= 400) return "\x1b[33m"; // yellow
	if (status >= 300) return "\x1b[36m"; // cyan

	return "\x1b[32m"; // green
}

morgan.token("method-colored", (req) => {
	const method = req.method ?? "???";
	const color = METHOD_COLOR[method] ?? RESET;

	return `${color}${BOLD}${method.padEnd(7)}${RESET}`;
});

morgan.token("status-colored", (_req, res) => {
	const status = res.statusCode;
	const color = statusColor(status);

	return `${color}${BOLD}${status}${RESET}`;
});

morgan.token("url-padded", (req) => {
	const url = req.url ?? "/";

	return url.length > 45 ? url.slice(0, 42) + "..." : url.padEnd(45);
});

morgan.token("response-time-fmt", (_req, res, digits) => {
	const start = (res as any)._startAt;
	const end = process.hrtime(start as [number, number]);
	const ms = end[0] * 1e3 + end[1] * 1e-6;
	const d = digits ? Number(digits) : 2;
	const formatted = ms.toFixed(d).padStart(8);
	const color = ms > 500 ? "\x1b[31m" : ms > 200 ? "\x1b[33m" : "\x1b[32m";

	return `${color}${formatted} ms${RESET}`;
});

morgan.token("timestamp", () => {
	return `${DIM}${new Date().toLocaleTimeString("en-GB")}${RESET}`;
});

const FORMAT =
	":timestamp  :method-colored  :url-padded  :status-colored  :response-time-fmt      :res[content-length] B";

export const httpLogger = morgan(FORMAT);
