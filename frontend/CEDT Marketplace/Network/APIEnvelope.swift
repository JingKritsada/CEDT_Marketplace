import Foundation

/// Wire-format envelope shared by every API response.
///
/// Success: `{ "success": true, "data": <payload> }`
/// Error:   `{ "success": false, "error": { "code": "...", "message": "...", "details": ... } }`
struct APIEnvelope<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIErrorBody?
}

struct APIErrorBody: Decodable {
    let code: String
    let message: String
    // `details` is intentionally untyped — the backend may put a string, a Zod issue list, etc.
    // The client doesn't need to interpret it; it's surfaced for logging only.
}
