import Combine
import Foundation

@MainActor
final class PostedItemsViewModel: ObservableObject {
    @Published var listings: [Listing] = []

    func update(from profile: UserProfile?) {
        listings = profile?.listings.filter { $0.sellerId == profile?.id } ?? []
    }
}
