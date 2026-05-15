import Foundation

final class WishlistService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchWishlist() async throws -> Wishlist {
        try await client.request(.wishlist)
    }

    func addItem(listingId: String) async throws -> WishlistItem {
        let payload = AddWishlistItemRequest(listingId: listingId)
        return try await client.request(.addToWishlist, body: payload)
    }

    func removeItem(listingId: String) async throws {
        try await client.request(.removeFromWishlist(listingId: listingId))
    }

    func clearWishlist() async throws {
        try await client.request(.clearWishlist)
    }
}
