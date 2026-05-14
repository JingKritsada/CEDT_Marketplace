import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let tokenInterceptor: TokenInterceptor

    init(
        session: URLSession = .shared,
        tokenInterceptor: TokenInterceptor = .shared
    ) {
        self.session = session
        self.tokenInterceptor = tokenInterceptor
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil) async throws -> T {
        let data = try await perform(endpoint, body: body)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func request(_ endpoint: Endpoint, body: Encodable? = nil) async throws {
        _ = try await perform(endpoint, body: body)
    }

    private func perform(_ endpoint: Endpoint, body: Encodable?) async throws -> Data {
        var request = try buildRequest(endpoint, body: body)
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401, endpoint.requiresAuth {
                    let newToken = try await tokenInterceptor.refreshTokens()
                    request = try buildRequest(endpoint, body: body, accessToken: newToken)
                    let (retryData, retryResponse) = try await session.data(for: request)
                    guard let retryHttp = retryResponse as? HTTPURLResponse else {
                        throw NetworkError.unknown
                    }
                    return try handleResponse(retryHttp, data: retryData)
                }
                return try handleResponse(httpResponse, data: data)
            }
            throw NetworkError.unknown
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).domain == NSURLErrorDomain {
                throw NetworkError.noInternet
            }
            throw NetworkError.unknown
        }
    }

    private func buildRequest(
        _ endpoint: Endpoint,
        body: Encodable?,
        accessToken: String? = KeychainManager.shared.accessToken
    ) throws -> URLRequest {
        guard let url = endpoint.url(baseURL: AppConfig.baseURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        if endpoint.requiresAuth {
            guard let token = accessToken else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        return request
    }

    private func handleResponse(_ response: HTTPURLResponse, data: Data) throws -> Data {
        switch response.statusCode {
        case 200 ... 299:
            return data
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 422:
            let message = decodeErrorMessage(from: data) ?? "Invalid input."
            throw NetworkError.validationError(message)
        default:
            let message = decodeErrorMessage(from: data) ?? "Server error."
            throw NetworkError.serverError(message)
        }
    }

    private func decodeErrorMessage(from data: Data) -> String? {
        struct ErrorResponse: Decodable {
            let message: String?
        }

        return try? decoder.decode(ErrorResponse.self, from: data).message
    }
}

private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        encodeFunc = encodable.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
