import AuthenticationServices
import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService
    private let socialAuthService: SocialAuthService

    init(authService: AuthService? = nil, socialAuthService: SocialAuthService? = nil) {
        self.authService = authService ?? AuthService()
        self.socialAuthService = socialAuthService ?? SocialAuthService()
    }

    func handleAppleSignIn(
        result: Result<ASAuthorization, Error>,
        session: SessionViewModel
    ) async {
        errorMessage = nil

        switch result {
        case let .failure(error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled { return }
            errorMessage = error.localizedDescription
            return
        case let .success(authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let identityToken = String(data: tokenData, encoding: .utf8)
            else {
                errorMessage = "Apple sign-in did not return an identity token."
                return
            }

            let fullName: AppleFullName? = {
                guard let name = credential.fullName,
                      name.givenName != nil || name.familyName != nil
                else { return nil }
                return AppleFullName(givenName: name.givenName, familyName: name.familyName)
            }()

            isLoading = true
            defer { isLoading = false }

            do {
                let response = try await authService.appleLogin(
                    identityToken: identityToken, fullName: fullName
                )
                session.handleAuthSuccess(response)
            } catch let error as NetworkError {
                errorMessage = error.userMessage
            } catch {
                errorMessage = NetworkError.unknown.userMessage
            }
        }
    }

    func signInWithSocial(provider: SocialProvider, session: SessionViewModel) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let tokens = try await socialAuthService.signIn(with: provider)
            await session.handleSocialAuthSuccess(tokens)
        } catch SocialAuthError.userCancelled {
            // User dismissed the sheet — stay quiet.
        } catch let error as SocialAuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func login(session: SessionViewModel) async {
        errorMessage = nil
        guard validateInputs() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await authService.login(email: email, password: password)
            session.handleAuthSuccess(response)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    private func validateInputs() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Email is required."
            return false
        }
        guard !password.isEmpty else {
            errorMessage = "Password is required."
            return false
        }
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return false
        }

        return true
    }
}
