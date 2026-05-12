import Foundation

final class PickupLocationService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchPickupLocations() async throws -> [PickupLocation] {
        try await client.request(.pickupLocations)
    }
}
