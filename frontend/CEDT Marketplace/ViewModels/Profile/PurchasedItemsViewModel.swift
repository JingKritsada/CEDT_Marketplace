import Combine
import Foundation

@MainActor
final class PurchasedItemsViewModel: ObservableObject {
    @Published var listings: [Listing] = []

    func update(from profile: UserProfile?) {
        listings = profile?.listings.filter { $0.buyerId == profile?.id } ?? []
    }
}
