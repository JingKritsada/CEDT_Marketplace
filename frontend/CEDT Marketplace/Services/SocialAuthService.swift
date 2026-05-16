import AuthenticationServices
import Foundation
import UIKit

enum SocialAuthError: LocalizedError {
    case invalidURL
    case userCancelled
    case missingTokens
    case providerError(String)
    case sessionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Could not build the sign-in URL."
        case .userCancelled: "Sign-in was cancelled."
        case .missingTokens: "Sign-in succeeded but no tokens were returned."
        case let .providerError(message): "Provider error: \(message)"
        case let .sessionFailed(message): "Sign-in failed: \(message)"
        }
    }
}

struct SocialAuthTokens {
    let accessToken: String
    let refreshToken: String
}

@MainActor
final class SocialAuthService: NSObject {
    private var currentSession: ASWebAuthenticationSession?

    /// Opens the platform web auth sheet, completes when the backend redirects
    /// back to `cedtmkt://auth/callback#access=...&refresh=...`.
    func signIn(with provider: SocialProvider) async throws -> SocialAuthTokens {
        guard
            let startURL = URL(
                string: "\(AppConfig.baseURL.absoluteString)/auth/oauth/\(provider.backendPath)/start"
            )
        else {
            throw SocialAuthError.invalidURL
        }

        let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: startURL,
                callbackURLScheme: "cedtmkt"
            ) { url, error in
                if let error = error as? ASWebAuthenticationSessionError,
                   error.code == .canceledLogin
                {
                    continuation.resume(throwing: SocialAuthError.userCancelled)
                    return
                }
                if let error {
                    continuation.resume(
                        throwing: SocialAuthError.sessionFailed(error.localizedDescription))
                    return
                }
                guard let url else {
                    continuation.resume(throwing: SocialAuthError.missingTokens)
                    return
                }
                continuation.resume(returning: url)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            currentSession = session

            if !session.start() {
                continuation.resume(
                    throwing: SocialAuthError.sessionFailed("Could not start web auth session."))
            }
        }

        return try parseTokens(from: callbackURL)
    }

    private func parseTokens(from url: URL) throws -> SocialAuthTokens {
        guard let fragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment else {
            throw SocialAuthError.missingTokens
        }

        // Re-parse the fragment as a query string.
        let items =
            URLComponents(string: "?\(fragment)")?.queryItems ?? []
        let lookup = Dictionary(uniqueKeysWithValues: items.compactMap { item -> (String, String)? in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })

        if let providerError = lookup["error"] {
            throw SocialAuthError.providerError(providerError)
        }

        guard let access = lookup["access"], let refresh = lookup["refresh"] else {
            throw SocialAuthError.missingTokens
        }

        return SocialAuthTokens(accessToken: access, refreshToken: refresh)
    }
}

extension SocialAuthService: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
        }
    }
}
