export class ApiError extends Error {
	readonly statusCode: number;
	readonly code: string;
	readonly details?: unknown;

	constructor(message: string, statusCode = 500, details?: unknown, code?: string) {
		super(message);
		this.name = "ApiError";
		this.statusCode = statusCode;
		this.code = code ?? defaultCodeForStatus(statusCode);
		this.details = details;
	}
}

function defaultCodeForStatus(status: number): string {
	switch (status) {
		case 400:
			return "BAD_REQUEST";
		case 401:
			return "UNAUTHORIZED";
		case 403:
			return "FORBIDDEN";
		case 404:
			return "NOT_FOUND";
		case 409:
			return "CONFLICT";
		case 422:
			return "VALIDATION_FAILED";
		case 429:
			return "RATE_LIMITED";
		default:
			return status >= 500 ? "INTERNAL_ERROR" : "ERROR";
	}
}
