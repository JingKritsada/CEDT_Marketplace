import Foundation

struct AppNotification: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let createdAt: Date
    var isRead: Bool
}
