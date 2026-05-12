import Foundation

final class UserService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getMe() async throws -> UserProfile {
        try await client.request(.me)
    }

    func updateProfile(_ payload: UpdateProfileRequest) async throws -> UserProfile {
        try await client.request(.updateProfile, body: payload)
    }
}
