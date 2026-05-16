import Foundation

enum SocialProvider: String, CaseIterable, Identifiable {
    case google
    case apple
    case facebook

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .google: "Google"
        case .apple: "Apple"
        case .facebook: "Facebook"
        }
    }

    /// Path segment used in the backend OAuth start endpoint:
    /// `<base>/auth/oauth/<path>/start`.
    var backendPath: String { rawValue }
}
