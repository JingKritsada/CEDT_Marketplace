import Foundation

final class ListingService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchListings(query: ListingQuery? = nil) async throws -> [Listing] {
        try await client.request(.listings(query: query))
    }

    func searchListings(query: ListingQuery? = nil) async throws -> [Listing] {
        try await client.request(.search(query: query))
    }

    func listingDetail(id: String) async throws -> Listing {
        try await client.request(.listingDetail(id: id))
    }

    func createListing(_ payload: CreateListingRequest) async throws -> Listing {
        try await client.request(.createListing, body: payload)
    }

    func updateListing(id: String, payload: UpdateListingRequest) async throws -> Listing {
        try await client.request(.updateListing(id: id), body: payload)
    }

    func deleteListing(id: String) async throws {
        try await client.request(.deleteListing(id: id))
    }

    func confirmReceived(id: String) async throws -> Listing {
        try await client.request(.confirmReceived(id: id))
    }

    func claimFree(id: String) async throws -> Listing {
        try await client.request(.claimFreeListing(id: id))
    }
}
