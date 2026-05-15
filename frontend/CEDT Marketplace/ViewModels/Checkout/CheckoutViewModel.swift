import Combine
import Foundation

@MainActor
final class CheckoutViewModel: ObservableObject {
    enum PaymentOutcome: Equatable {
        case succeeded
        case canceled
        case failed(String)
    }

    @Published var errorMessage: String?
    @Published var listing: Listing?
    @Published var isLoading = false

    /// Stripe state, populated after `/checkout` returns.
    @Published var checkoutResponse: CheckoutResponse?

    /// True while we wait for the user to interact with PaymentSheet.
    @Published var isPaymentSheetActive = false

    /// Final payment outcome — drives the success/failure UI.
    @Published var paymentOutcome: PaymentOutcome?

    private let paymentService: PaymentService

    init(paymentService: PaymentService? = nil) {
        self.paymentService = paymentService ?? PaymentService()
    }

    func configure(with listing: Listing) {
        self.listing = listing
    }

    var subtotal: Int {
        guard let listing else { return 0 }
        return listing.isFree ? 0 : listing.price
    }

    var pickupLocation: PickupLocation? {
        listing?.pickupLocation
    }

    func startCheckout() async {
        errorMessage = nil
        checkoutResponse = nil
        paymentOutcome = nil

        guard let listing else {
            errorMessage = "No item to check out."
            return
        }

        if listing.isFree || listing.price <= 0 {
            errorMessage = "Free items don't need checkout."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await paymentService.checkout(listingId: listing.id)
            checkoutResponse = response
            isPaymentSheetActive = true
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func handlePaymentOutcome(_ outcome: PaymentOutcome) {
        isPaymentSheetActive = false
        paymentOutcome = outcome
        if case let .failed(message) = outcome {
            errorMessage = message
        }
    }
}
