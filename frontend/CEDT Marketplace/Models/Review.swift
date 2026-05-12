import Foundation

struct Review: Codable, Identifiable {
    let id: String
    let rating: Int
    let comment: String?
    let reviewer: UserSummary?
    let createdAt: Date?
}

struct CreateReviewRequest: Codable {
    let listingId: String
    let rating: Int
    let comment: String?
}
