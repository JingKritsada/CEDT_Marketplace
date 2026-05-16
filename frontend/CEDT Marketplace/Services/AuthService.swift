import Foundation

final class AuthService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let payload = LoginRequest(email: email, password: password)
        return try await client.request(.login, body: payload)
    }

    func register(studentId: String, email: String, displayName: String, password: String)
        async throws -> AuthResponse
    {
        let payload = RegisterRequest(
            studentId: studentId, email: email, displayName: displayName, password: password
        )
        return try await client.request(.register, body: payload)
    }

    func refresh(refreshToken: String) async throws -> TokenResponse {
        let payload = RefreshTokenRequest(refreshToken: refreshToken)
        return try await client.request(.refreshToken, body: payload)
    }

    func logout(refreshToken: String) async throws {
        let payload = RefreshTokenRequest(refreshToken: refreshToken)
        try await client.request(.logout, body: payload)
    }

    func appleLogin(identityToken: String, fullName: AppleFullName?) async throws -> AuthResponse {
        let payload = AppleLoginRequest(identityToken: identityToken, fullName: fullName)
        return try await client.request(.appleLogin, body: payload)
    }
}
