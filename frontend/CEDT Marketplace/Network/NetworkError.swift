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
            return "Invalid URL"
        case .unauthorized:
            return "Please sign in again."
        case .forbidden:
            return "You do not have permission to do that."
        case .notFound:
            return "The requested resource was not found."
        case .validationError(let message):
            return message
        case .serverError(let message):
            return message
        case .decodingFailed:
            return "Failed to read server response."
        case .noInternet:
            return "No internet connection."
        case .unknown:
            return "Something went wrong."
        }
    }
}
