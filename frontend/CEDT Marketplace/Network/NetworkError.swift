import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case serverError(String, code: String? = nil)
    case decodingFailed
    case noInternet
    case unknown

    var userMessage: String {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .unauthorized:
            "Please sign in again."
        case .forbidden:
            "You do not have permission to do that."
        case .notFound:
            "The requested resource was not found."
        case let .validationError(message):
            message
        case let .serverError(message, _):
            message
        case .decodingFailed:
            "Failed to read server response."
        case .noInternet:
            "No internet connection."
        case .unknown:
            "Something went wrong."
        }
    }

    /// Optional machine-readable code from the server envelope (e.g. "AUTH_001"). Available on `.serverError` only.
    var code: String? {
        if case let .serverError(_, code) = self { return code }
        return nil
    }
}
