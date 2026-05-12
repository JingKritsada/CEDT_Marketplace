import Foundation

final class ReviewService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func reviewsByListing(listingId: String) async throws -> [Review] {
        try await client.request(.reviewsByListing(listingId: listingId))
    }

    func reviewsBySeller(sellerId: String) async throws -> [Review] {
        try await client.request(.reviewsBySeller(sellerId: sellerId))
    }

    func createReview(_ payload: CreateReviewRequest) async throws -> Review {
        try await client.request(.createReview, body: payload)
    }
}
