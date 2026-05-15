import Foundation

enum ListingStatus: String, Codable, CaseIterable {
    case available = "AVAILABLE"
    case reserved = "RESERVED"
    case waitingForPayment = "WAITING_FOR_PAYMENT"
    case paid = "PAID"
    case waitingForPickup = "WAITING_FOR_PICKUP"
    case sent = "SENT"
    case received = "RECEIVED"
    case rated = "RATED"
    case sold = "SOLD"

    var displayName: String {
        switch self {
        case .available:
            "Available"
        case .reserved:
            "Reserved"
        case .waitingForPayment:
            "Waiting for Payment"
        case .paid:
            "Paid"
        case .waitingForPickup:
            "Waiting for Pickup"
        case .sent:
            "Sent"
        case .received:
            "Received"
        case .rated:
            "Rated"
        case .sold:
            "Sold"
        }
    }
}

enum ListingCondition: String, Codable, CaseIterable {
    case new = "NEW"
    case likeNew = "LIKE_NEW"
    case good = "GOOD"
    case fair = "FAIR"
    case poor = "POOR"

    var displayName: String {
        switch self {
        case .new:
            "New"
        case .likeNew:
            "Like New"
        case .good:
            "Good"
        case .fair:
            "Fair"
        case .poor:
            "Poor"
        }
    }
}

struct Listing: Codable, Identifiable {
    let id: String
    let sellerId: String?
    let buyerId: String?
    let title: String
    let description: String
    let price: Int
    let isFree: Bool
    let status: ListingStatus
    let condition: ListingCondition?
    let courseCode: String?
    let categoryId: String?
    let pickupLocationId: String?
    let images: [String]
    let createdAt: Date?
    let updatedAt: Date?
    let seller: UserSummary?
    let buyer: UserSummary?
    let category: Category?
    let pickupLocation: PickupLocation?
    let reviews: [Review]?
}

struct ListingQuery: Codable, Equatable {
    var categoryId: String?
    var courseCode: String?
    var isFree: Bool?
    var minPrice: Int?
    var maxPrice: Int?
    var status: ListingStatus?
    var search: String?

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let categoryId {
            items.append(URLQueryItem(name: "categoryId", value: categoryId))
        }
        if let courseCode {
            items.append(URLQueryItem(name: "courseCode", value: courseCode))
        }
        if let isFree {
            items.append(URLQueryItem(name: "isFree", value: String(isFree)))
        }
        if let minPrice {
            items.append(URLQueryItem(name: "minPrice", value: String(minPrice)))
        }
        if let maxPrice {
            items.append(URLQueryItem(name: "maxPrice", value: String(maxPrice)))
        }
        if let status {
            items.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        if let search {
            items.append(URLQueryItem(name: "search", value: search))
        }
        return items
    }
}

struct CreateListingRequest: Codable {
    let title: String
    let description: String
    let price: Int
    let isFree: Bool
    let courseCode: String?
    let categoryId: String
    let pickupLocationId: String
    let images: [String]
    let condition: ListingCondition
}

struct UpdateListingRequest: Codable {
    let title: String?
    let description: String?
    let price: Int?
    let isFree: Bool?
    let courseCode: String?
    let categoryId: String?
    let pickupLocationId: String?
    let images: [String]?
    let status: ListingStatus?
    let buyerId: String?
    let condition: ListingCondition?
}
