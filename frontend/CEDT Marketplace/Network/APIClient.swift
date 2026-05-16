import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let tokenInterceptor: TokenInterceptor

    init(
        session: URLSession? = nil,
        tokenInterceptor: TokenInterceptor = .shared
    ) {
        if let session {
            self.session = session
        } else {
            // Dedicated session avoids URLSession.shared's global keep-alive pool, which
            // strands stale sockets after the server's keepAliveTimeout. Shorter
            // per-request timeout so dead connections surface fast and retry kicks in.
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 30
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            self.session = URLSession(configuration: config)
        }
        self.tokenInterceptor = tokenInterceptor
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil) async throws -> T {
        let data = try await perform(endpoint, body: body)
        let envelope: APIEnvelope<T>
        do {
            envelope = try decoder.decode(APIEnvelope<T>.self, from: data)
        } catch {
            let preview = String(data: data.prefix(200), encoding: .utf8) ?? "<non-utf8>"
            print("❌ [API] decode failed for \(T.self) — \(data.count)B preview: \(preview)")
            print("❌ [API] underlying: \(error)")
            throw NetworkError.decodingFailed
        }

        if envelope.success, let payload = envelope.data {
            return payload
        }

        if let apiError = envelope.error {
            throw NetworkError.serverError(apiError.message, code: apiError.code)
        }

        throw NetworkError.decodingFailed
    }

    func request(_ endpoint: Endpoint, body: Encodable? = nil) async throws {
        _ = try await perform(endpoint, body: body)
    }

    private func perform(_ endpoint: Endpoint, body: Encodable?) async throws -> Data {
        var request = try buildRequest(endpoint, body: body)
        let urlStr = request.url?.absoluteString ?? "?"
        let method = request.httpMethod ?? "?"
        let started = Date()
        print("➡️ [API] \(method) \(urlStr)")
        do {
            let (data, response) = try await sendWithRetry(request)
            let elapsedMs = Int(Date().timeIntervalSince(started) * 1000)
            if let httpResponse = response as? HTTPURLResponse {
                print(
                    "⬅️ [API] \(method) \(urlStr) → \(httpResponse.statusCode) (\(data.count)B, \(elapsedMs)ms)"
                )
                if httpResponse.statusCode == 401, endpoint.requiresAuth {
                    let newToken = try await tokenInterceptor.refreshTokens()
                    request = try buildRequest(endpoint, body: body, accessToken: newToken)
                    let (retryData, retryResponse) = try await sendWithRetry(request)
                    guard let retryHttp = retryResponse as? HTTPURLResponse else {
                        throw NetworkError.unknown
                    }
                    print(
                        "⬅️ [API] (retry-after-401) \(method) \(urlStr) → \(retryHttp.statusCode) (\(retryData.count)B)"
                    )
                    return try handleResponse(retryHttp, data: retryData)
                }
                return try handleResponse(httpResponse, data: data)
            }
            print("❌ [API] \(method) \(urlStr) → non-HTTP response")
            throw NetworkError.unknown
        } catch let error as NetworkError {
            print("❌ [API] \(method) \(urlStr) → NetworkError \(error)")
            throw error
        } catch {
            let ns = error as NSError
            // -999 (cancelled) means SwiftUI killed the parent Task — not a network failure.
            // Propagate as CancellationError so callers can ignore it instead of showing a banner.
            if ns.domain == NSURLErrorDomain, ns.code == NSURLErrorCancelled {
                print("⏹ [API] \(method) \(urlStr) → cancelled (no error banner)")
                throw CancellationError()
            }
            print(
                "❌ [API] \(method) \(urlStr) → URLError code=\(ns.code) domain=\(ns.domain) desc=\(ns.localizedDescription)"
            )
            throw mapURLError(error)
        }
    }

    /// Sends the request, retrying once for transient failures that happen when iOS
    /// reuses a server-closed keep-alive socket. Two failure shapes are handled:
    /// (1) `URLSession` throws (-1001/-1005/etc.), or
    /// (2) `URLSession` returns "successfully" with a 2xx status and an empty body —
    ///     a phantom response that comes back when the socket died after headers
    ///     but before the body. Decoding would otherwise fail with "Failed to read server response."
    private func sendWithRetry(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            if isPhantomEmptyResponse(data: data, response: response, method: request.httpMethod) {
                return try await session.data(for: request)
            }
            return (data, response)
        } catch {
            guard isTransientConnectionError(error) else { throw error }
            return try await session.data(for: request)
        }
    }

    /// True when the server returned a 2xx that should have had a body but didn't.
    /// 204 is excluded because empty is the contract there.
    private func isPhantomEmptyResponse(data: Data, response: URLResponse, method: String?) -> Bool {
        guard data.isEmpty else { return false }
        guard let http = response as? HTTPURLResponse else { return false }
        guard (200 ... 299).contains(http.statusCode), http.statusCode != 204 else { return false }
        // DELETE is the main legitimate-empty case (status varies); don't retry it.
        if method == "DELETE" { return false }
        return true
    }

    private func isTransientConnectionError(_ error: Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }
        switch nsError.code {
        case NSURLErrorNetworkConnectionLost, // -1005, stale keep-alive socket
             NSURLErrorTimedOut, // -1001
             NSURLErrorCannotConnectToHost, // -1004
             NSURLErrorCannotFindHost: // -1003
            return true
        default:
            return false
        }
    }

    private func mapURLError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return .unknown }
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .noInternet
        case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost, NSURLErrorCannotConnectToHost:
            return .serverError("The server didn't respond. Please try again.")
        default:
            return .noInternet
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
        // Disable HTTP keep-alive on the client side. Forces a fresh TCP connection per
        // request so we never grab a stale pooled socket that the server has already closed.
        // Costs a few ms per request locally; avoids the "phantom 200 with empty body" bug.
        request.setValue("close", forHTTPHeaderField: "Connection")

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
            let body = decodeErrorBody(from: data)
            throw NetworkError.validationError(body?.message ?? "Invalid input.")
        default:
            let body = decodeErrorBody(from: data)
            throw NetworkError.serverError(body?.message ?? "Server error.", code: body?.code)
        }
    }

    private func decodeErrorBody(from data: Data) -> APIErrorBody? {
        // Envelope path: { success: false, error: { code, message, details } }
        struct Wrapper: Decodable { let error: APIErrorBody? }
        if let wrapped = try? decoder.decode(Wrapper.self, from: data), let error = wrapped.error {
            return error
        }
        return nil
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
