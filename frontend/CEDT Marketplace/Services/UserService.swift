import Foundation

final class UserService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getMe() async throws -> UserProfile {
        try await client.request(.me)
    }

    func getUser(id: String) async throws -> UserProfile {
        try await client.request(.user(id: id))
    }

    func updateProfile(_ payload: UpdateProfileRequest) async throws -> UserProfile {
        try await client.request(.updateProfile, body: payload)
    }
}
