import Combine
import Foundation

@MainActor
final class SoldItemsViewModel: ObservableObject {
    @Published var listings: [Listing] = []

    func update(from profile: UserProfile?) {
        listings = profile?.listings.filter { $0.status == .sold || $0.status == .rated } ?? []
    }
}
