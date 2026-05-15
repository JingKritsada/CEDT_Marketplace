import Foundation

final class PaymentService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func checkout(listingId: String) async throws -> CheckoutResponse {
        try await client.request(.checkout, body: CheckoutRequest(listingId: listingId))
    }

    func myPayments() async throws -> [Payment] {
        try await client.request(.payments)
    }

    func payment(id: String) async throws -> Payment {
        try await client.request(.paymentDetail(id: id))
    }

    func cancel(id: String) async throws -> Payment {
        try await client.request(.cancelPayment(id: id))
    }

    func refund(id: String, amountSatang: Int? = nil, reason: String? = nil) async throws -> Payment {
        let payload = CreateRefundRequest(amountSatang: amountSatang, reason: reason)
        return try await client.request(.refundPayment(id: id), body: payload)
    }
}
