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
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

#Preview {
    StatusBadge(status: .available)
        .padding()
        .previewLayout(.sizeThatFits)
}
