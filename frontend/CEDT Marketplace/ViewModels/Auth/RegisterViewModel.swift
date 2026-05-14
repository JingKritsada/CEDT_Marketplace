import Combine
import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var studentId = ""
    @Published var email = ""
    @Published var displayName = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }

    func register(session: SessionViewModel) async {
        errorMessage = nil
        guard validateInputs() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await authService.register(
                studentId: studentId,
                email: email,
                displayName: displayName,
                password: password
            )
            session.handleAuthSuccess(response)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    private func validateInputs() -> Bool {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Full name is required."
            return false
        }
        guard !studentId.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Student ID is required."
            return false
        }
        guard studentId.count == 10, studentId.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Student ID must be 10 digits."
            return false
        }
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
        guard !confirmPassword.isEmpty else {
            errorMessage = "Confirm password is required."
            return false
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        return true
    }
}
