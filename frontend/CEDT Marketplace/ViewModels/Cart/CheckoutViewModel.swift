import Combine
import Foundation

@MainActor
final class CheckoutViewModel: ObservableObject {
    @Published var selectedPickupLocationId: String?
    @Published var errorMessage: String?
    @Published var isConfirmed = false

    func confirmOrder() {
        guard selectedPickupLocationId != nil else {
            errorMessage = "Pickup location is required."
            return
        }
        isConfirmed = true
    }
}
