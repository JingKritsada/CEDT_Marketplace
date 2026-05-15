import Foundation

enum PaymentStatus: String, Codable {
    case requiresPaymentMethod = "REQUIRES_PAYMENT_METHOD"
    case requiresAction = "REQUIRES_ACTION"
    case processing = "PROCESSING"
    case requiresCapture = "REQUIRES_CAPTURE"
    case succeeded = "SUCCEEDED"
    case canceled = "CANCELED"
    case failed = "FAILED"
    case refunded = "REFUNDED"
    case partiallyRefunded = "PARTIALLY_REFUNDED"

    var displayName: String {
        switch self {
        case .requiresPaymentMethod: "Awaiting payment"
        case .requiresAction: "Awaiting confirmation"
        case .processing: "Processing"
        case .requiresCapture: "Authorized — awaiting pickup"
        case .succeeded: "Paid"
        case .canceled: "Canceled"
        case .failed: "Failed"
        case .refunded: "Refunded"
        case .partiallyRefunded: "Partially refunded"
        }
    }
}

/// Response from `POST /checkout`. Contains everything needed to present
/// Stripe's PaymentSheet on the buyer's device.
struct CheckoutResponse: Codable {
    let paymentId: String
    let paymentIntentId: String
    let clientSecret: String
    let publishableKey: String?
    let amountSatang: Int
    let platformFeeSatang: Int
    let currency: String
}

/// `Payment` row as returned by `GET /payments/:id` and `GET /payments`.
struct Payment: Codable, Identifiable {
    let id: String
    let buyerId: String
    let sellerId: String
    let listingId: String
    let stripePaymentIntentId: String
    let stripeChargeId: String?
    let stripeApplicationFeeId: String?
    let stripeTransferId: String?
    let amountSatang: Int
    let platformFeeSatang: Int
    let sellerNetSatang: Int
    let currency: String
    let status: PaymentStatus
    let paymentMethodType: String?
    let captureMethod: String?
    let capturedAt: Date?
    let succeededAt: Date?
    let canceledAt: Date?
    let failureCode: String?
    let failureMessage: String?
    let createdAt: Date
    let updatedAt: Date
    let listing: Listing?
    let seller: UserSummary?
    let buyer: UserSummary?
}

struct CreateRefundRequest: Codable {
    let amountSatang: Int?
    let reason: String?
}

struct CheckoutRequest: Codable {
    let listingId: String
}
