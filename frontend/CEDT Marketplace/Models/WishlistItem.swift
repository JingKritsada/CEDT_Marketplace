import Foundation

struct Wishlist: Codable, Identifiable {
    let id: String
    let items: [WishlistItem]
}

struct WishlistItem: Codable, Identifiable {
    let id: String
    let listingId: String
    let quantity: Int
    let listing: Listing
}

struct AddWishlistItemRequest: Codable {
    let listingId: String
}
