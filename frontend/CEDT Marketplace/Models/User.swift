import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let displayName: String
    let studentId: String?
}

struct UserSummary: Codable, Identifiable {
    let id: String
    let displayName: String
    let avatarUrl: String?
    let lineId: String? = nil
    let instagram: String? = nil
    let facebookUrl: String? = nil
}

struct RatingSummary: Codable {
    let average: Double
    let count: Int
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String
    let displayName: String
    let studentId: String?
    let avatarUrl: String?
    let lineId: String?
    let instagram: String?
    let facebookUrl: String?
    let createdAt: Date
    let listings: [Listing]
    let rating: RatingSummary
}

struct UpdateProfileRequest: Codable {
    let displayName: String?
    let avatarUrl: String?
    let lineId: String?
    let instagram: String?
    let facebookUrl: String?
}
