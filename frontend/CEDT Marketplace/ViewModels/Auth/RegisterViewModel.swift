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
        if studentId.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Student ID is required."
            return false
        }
        if displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Display name is required."
            return false
        }
        if !email.lowercased().hasSuffix("@\(AppConfig.studentEmailDomain)") {
            errorMessage = "Use your university email."
            return false
        }
        if password.count < 8 {
            errorMessage = "Password must be at least 8 characters."
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        return true
    }
}
