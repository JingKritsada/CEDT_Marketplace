import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let studentId: String
    let email: String
    let displayName: String
    let password: String
}

struct AppleFullName: Codable {
    let givenName: String?
    let familyName: String?
}

struct AppleLoginRequest: Codable {
    let identityToken: String
    let fullName: AppleFullName?
}
