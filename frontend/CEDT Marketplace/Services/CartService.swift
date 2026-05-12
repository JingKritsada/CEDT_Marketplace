import Foundation

final class CartService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchCart() async throws -> Cart {
        try await client.request(.cart)
    }

    func addItem(listingId: String) async throws -> CartItem {
        let payload = AddCartItemRequest(listingId: listingId)
        return try await client.request(.addToCart, body: payload)
    }

    func removeItem(listingId: String) async throws {
        try await client.request(.removeFromCart(listingId: listingId))
    }

    func clearCart() async throws {
        try await client.request(.clearCart)
    }
}
