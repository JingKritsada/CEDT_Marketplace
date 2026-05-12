import Foundation

struct PickupLocation: Codable, Identifiable {
    let id: String
    let name: String
    let building: String
    let description: String?
}
