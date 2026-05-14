import SwiftUI

struct StatusBadge: View {
    let status: ListingStatus

    private var color: Color {
        switch status {
        case .available:
            return .statusAvailable
        case .reserved, .waitingForPayment:
            return .statusReserved
        case .paid, .waitingForPickup, .sent, .received:
            return .statusInfo
        case .rated, .sold:
            return .statusSold
        }
    }

    var body: some View {
        Text(status.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    StatusBadge(status: .available)
        .padding()
}
