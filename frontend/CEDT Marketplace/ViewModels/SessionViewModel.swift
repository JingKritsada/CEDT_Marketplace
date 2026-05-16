import Combine
import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published var currentUser: User?

    private let userService: UserService

    init(userService: UserService? = nil) {
        self.userService = userService ?? UserService()
        Task { await restoreSession() }
    }

    func restoreSession() async {
        if KeychainManager.shared.accessToken != nil {
            isAuthenticated = true
            await fetchProfile()
        } else {
            isAuthenticated = false
        }
    }

    func handleAuthSuccess(_ response: AuthResponse) {
        KeychainManager.shared.accessToken = response.accessToken
        KeychainManager.shared.refreshToken = response.refreshToken
        currentUser = response.user
        isAuthenticated = true
    }

    /// Used by social-login flows that only return tokens via the OAuth callback.
    /// Stores tokens, marks the session authenticated, then loads the profile.
    func handleSocialAuthSuccess(_ tokens: SocialAuthTokens) async {
        KeychainManager.shared.accessToken = tokens.accessToken
        KeychainManager.shared.refreshToken = tokens.refreshToken
        isAuthenticated = true
        await fetchProfile()
    }

    func logout() {
        KeychainManager.shared.clearAll()
        currentUser = nil
        isAuthenticated = false
    }

    func fetchProfile() async {
        do {
            let profile = try await userService.getMe()
            currentUser = User(
                id: profile.id, email: profile.email, displayName: profile.displayName,
                studentId: profile.studentId
            )
        } catch {
            KeychainManager.shared.clearAll()
            isAuthenticated = false
        }
    }
}
