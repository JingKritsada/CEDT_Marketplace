import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
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
            errorMessage = "University email is required."
            return false
        }
        guard email.lowercased().hasSuffix("@\(AppConfig.studentEmailDomain)") else {
            errorMessage = "Use university email (\(AppConfig.studentEmailDomain))."
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
