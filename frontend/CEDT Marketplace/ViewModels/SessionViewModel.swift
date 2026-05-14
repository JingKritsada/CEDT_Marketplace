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
