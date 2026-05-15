import SafariServices
import SwiftUI

/// Simple wrapper around `SFSafariViewController` so SwiftUI can present a hosted web page
/// for Stripe Connect onboarding (the only place we link out of the app).
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.preferredControlTintColor = UIColor.systemPink
        return controller
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}
