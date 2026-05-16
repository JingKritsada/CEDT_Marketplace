/**
 * Standard API response envelope.
 *
 * Success:
 *   { "success": true, "data": <payload> }
 *
 * Error:
 *   { "success": false, "error": { "code": "...", "message": "...", "details": ... } }
 */

export interface ApiSuccess<T> {
	success: true;
	data: T;
}

export interface ApiFailure {
	success: false;
	error: {
		code: string;
		message: string;
		details?: unknown;
	};
}

export type ApiEnvelope<T> = ApiSuccess<T> | ApiFailure;

/** Wraps a value in a success envelope. */
export const ok = <T>(data: T): ApiSuccess<T> => ({
	success: true,
	data,
});

/** Builds an error envelope. Used by the error handler; controllers should throw ApiError instead. */
export const fail = (code: string, message: string, details?: unknown): ApiFailure => ({
	success: false,
	error: { code, message, details },
});
