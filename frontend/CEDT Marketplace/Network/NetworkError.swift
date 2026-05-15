import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case serverError(String)
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
        case let .serverError(message):
            message
        case .decodingFailed:
            "Failed to read server response."
        case .noInternet:
            "No internet connection."
        case .unknown:
            "Something went wrong."
        }
    }
}
