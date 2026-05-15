import StripePaymentSheet
import SwiftUI
import UIKit

/// Bridges Stripe's UIKit-based `PaymentSheet` into SwiftUI.
///
/// Usage:
/// ```
/// .background(
///     PaymentSheetPresenter(
///         isActive: $vm.isPaymentSheetActive,
///         clientSecret: vm.checkoutResponse?.clientSecret,
///         publishableKey: vm.checkoutResponse?.publishableKey,
///         onCompletion: vm.handlePaymentOutcome
///     )
/// )
/// ```
struct PaymentSheetPresenter: UIViewControllerRepresentable {
    @Binding var isActive: Bool
    let clientSecret: String?
    let publishableKey: String?
    let merchantDisplayName: String
    let onCompletion: (CheckoutViewModel.PaymentOutcome) -> Void

    init(
        isActive: Binding<Bool>,
        clientSecret: String?,
        publishableKey: String?,
        merchantDisplayName: String = "CEDT Marketplace",
        onCompletion: @escaping (CheckoutViewModel.PaymentOutcome) -> Void
    ) {
        _isActive = isActive
        self.clientSecret = clientSecret
        self.publishableKey = publishableKey
        self.merchantDisplayName = merchantDisplayName
        self.onCompletion = onCompletion
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ controller: UIViewController, context _: Context) {
        guard isActive,
              let clientSecret,
              !clientSecret.isEmpty,
              controller.presentedViewController == nil else { return }

        if let publishableKey, !publishableKey.isEmpty {
            STPAPIClient.shared.publishableKey = publishableKey
        }

        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = merchantDisplayName
        configuration.allowsDelayedPaymentMethods = false

        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret, configuration: configuration
        )

        DispatchQueue.main.async {
            paymentSheet.present(from: controller) { result in
                let outcome: CheckoutViewModel.PaymentOutcome = switch result {
                case .completed: .succeeded
                case .canceled: .canceled
                case let .failed(error): .failed(error.localizedDescription)
                }
                onCompletion(outcome)
            }
        }
    }
}
