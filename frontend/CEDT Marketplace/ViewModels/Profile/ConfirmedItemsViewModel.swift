import Combine
import Foundation

@MainActor
final class ConfirmedItemsViewModel: ObservableObject {
    @Published var listings: [Listing] = []

    func update(from profile: UserProfile?) {
        listings =
            profile?.listings.filter { $0.status == .waitingForPickup || $0.status == .sent } ?? []
    }
}
