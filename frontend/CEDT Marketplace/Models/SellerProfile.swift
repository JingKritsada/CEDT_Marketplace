import Foundation

enum SellerConnectStatus: String, Codable {
    case none = "NONE"
    case pending = "PENDING"
    case active = "ACTIVE"
    case restricted = "RESTRICTED"
    case rejected = "REJECTED"

    var displayName: String {
        switch self {
        case .none: "Not registered"
        case .pending: "Pending verification"
        case .active: "Active"
        case .restricted: "Action required"
        case .rejected: "Rejected"
        }
    }
}

struct SellerProfile: Codable, Identifiable {
    let id: String
    let userId: String
    let stripeConnectAccountId: String?
    let connectStatus: SellerConnectStatus
    let chargesEnabled: Bool
    let payoutsEnabled: Bool
    let detailsSubmitted: Bool
    let requirementsDisabledReason: String?
    let requirementsCurrentlyDue: [String]
    let defaultPayoutCurrency: String
    /// BigInt in backend — surfaced as string by the JSON serializer (see app.ts).
    let totalEarnedSatang: String
    let totalPaidOutSatang: String
    let createdAt: Date
    let updatedAt: Date

    var canAcceptPayments: Bool {
        connectStatus == .active && chargesEnabled && payoutsEnabled
    }

    var totalEarnedTHB: Int {
        (Int(totalEarnedSatang) ?? 0) / 100
    }

    var totalPaidOutTHB: Int {
        (Int(totalPaidOutSatang) ?? 0) / 100
    }
}

struct StartOnboardingResponse: Codable {
    let url: String
    let expiresAt: Int?
    let stripeConnectAccountId: String
}

/// Mirrors Stripe's `Balance` object as returned by `stripe.balance.retrieve`.
struct StripeBalance: Codable {
    struct Bucket: Codable {
        let amount: Int
        let currency: String
    }

    let available: [Bucket]
    let pending: [Bucket]

    func availableSatang(currency: String = "thb") -> Int {
        available.first(where: { $0.currency.lowercased() == currency.lowercased() })?.amount ?? 0
    }

    func pendingSatang(currency: String = "thb") -> Int {
        pending.first(where: { $0.currency.lowercased() == currency.lowercased() })?.amount ?? 0
    }
}

/// Mirrors Stripe's `Payout` object.
struct StripePayout: Codable, Identifiable {
    let id: String
    let amount: Int
    let currency: String
    let status: String
    let arrivalDate: Int?
    let created: Int?
    let description: String?

    var arrivalDateValue: Date? {
        guard let arrivalDate else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(arrivalDate))
    }
}

struct StripePayoutList: Codable {
    let data: [StripePayout]
    let hasMore: Bool?

    enum CodingKeys: String, CodingKey {
        case data
        case hasMore = "has_more"
    }
}
