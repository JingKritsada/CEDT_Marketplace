import Foundation

struct Cart: Codable, Identifiable {
    let id: String
    let items: [CartItem]
}

struct CartItem: Codable, Identifiable {
    let id: String
    let listingId: String
    let quantity: Int
    let listing: Listing
}

struct AddCartItemRequest: Codable {
    let listingId: String
}
