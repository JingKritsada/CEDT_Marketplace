import Foundation

final class TokenInterceptor {
    static let shared = TokenInterceptor()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func refreshTokens() async throws -> String {
        guard let refreshToken = KeychainManager.shared.refreshToken else {
            throw NetworkError.unauthorized
        }

        let endpoint = Endpoint.refreshToken
        guard let url = endpoint.url(baseURL: AppConfig.baseURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RefreshTokenRequest(refreshToken: refreshToken)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.unauthorized
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        KeychainManager.shared.accessToken = tokenResponse.accessToken
        KeychainManager.shared.refreshToken = tokenResponse.refreshToken
        return tokenResponse.accessToken
    }
}
