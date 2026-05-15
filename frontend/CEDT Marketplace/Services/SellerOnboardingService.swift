import Foundation

final class SellerOnboardingService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func startOnboarding() async throws -> StartOnboardingResponse {
        try await client.request(.sellerOnboarding)
    }

    func refreshStatus() async throws -> SellerProfile {
        try await client.request(.sellerOnboardingRefresh)
    }

    func myProfile() async throws -> SellerProfile {
        try await client.request(.sellerMe)
    }

    func balance() async throws -> StripeBalance {
        try await client.request(.sellerBalance)
    }

    func payouts() async throws -> StripePayoutList {
        try await client.request(.sellerPayouts)
    }
}
