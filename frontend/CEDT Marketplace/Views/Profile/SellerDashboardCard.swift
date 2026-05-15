import SwiftUI

/// Seller card inside ProfileView. Surfaces three states:
/// 1. **Not registered** → "Become a Seller" CTA
/// 2. **Pending / restricted** → status banner + requirements + "Continue onboarding"
/// 3. **Active** → earnings summary + refresh affordance
struct SellerDashboardCard: View {
    @ObservedObject var viewModel: ProfileViewModel

    private let cardCornerRadius: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Seller dashboard", systemImage: "storefront")
                .font(.headline)
                .foregroundColor(.primary)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        if let seller = viewModel.sellerProfile {
            statusBanner(seller)

            if !seller.requirementsCurrentlyDue.isEmpty {
                requirementsList(seller.requirementsCurrentlyDue)
            }

            if seller.canAcceptPayments {
                earningsSummary(seller)
            }

            actionButtons(for: seller)
        } else {
            notRegisteredState
        }
    }

    private var notRegisteredState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Earn from items you no longer need.")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            Text(
                "Register a Stripe Connect account to start receiving payments for the items you list. Your earnings are paid out to a Thai bank account."
            )
            .font(.caption)
            .foregroundColor(.secondary)

            PrimaryButton(
                title: "Become a Seller",
                action: { Task { await viewModel.startSellerOnboarding() } },
                paddingSize: 6,
                isLoading: viewModel.isStartingOnboarding
            )
            .font(.subheadline.weight(.semibold))
            .padding(.top, 4)
        }
    }

    private func statusBanner(_ seller: SellerProfile) -> some View {
        let (icon, color, message) = statusVisuals(for: seller)

        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(seller.connectStatus.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statusVisuals(for seller: SellerProfile) -> (String, Color, String) {
        switch seller.connectStatus {
        case .none:
            ("circle.dashed", .statusSold, "Not registered yet.")
        case .pending:
            (
                "hourglass.circle.fill",
                .statusReserved,
                "Stripe is reviewing your details. Some items may still need your input."
            )
        case .active:
            (
                "checkmark.seal.fill",
                .statusAvailable,
                "You can accept payments. Funds are paid to your bank ~7 business days after each sale."
            )
        case .restricted:
            (
                "exclamationmark.triangle.fill",
                .statusReserved,
                seller.requirementsDisabledReason
                    ?? "Stripe needs more information before you can accept payments."
            )
        case .rejected:
            (
                "xmark.octagon.fill", .accentSecondary, "Your account was rejected. Please contact support."
            )
        }
    }

    private func requirementsList(_ requirements: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("REQUIREMENTS")
                .font(.caption.weight(.heavy))
                .foregroundColor(.secondary)

            ForEach(requirements, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.statusReserved)
                        .padding(.top, 6)
                    Text(humanize(item))
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func humanize(_ key: String) -> String {
        key
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: ".", with: " · ")
            .capitalized
    }

    private func earningsSummary(_ seller: SellerProfile) -> some View {
        HStack(spacing: 12) {
            statCard(
                label: "Total earned", value: "฿\(seller.totalEarnedTHB)", tint: .accentPrimary,
                systemImage: "bahtsign.circle.fill"
            )
            statCard(
                label: "Paid out", value: "฿\(seller.totalPaidOutTHB)", tint: .statusAvailable,
                systemImage: "checkmark.circle.fill"
            )
        }
    }

    private func statCard(label: String, value: String, tint: Color, systemImage: String)
        -> some View
    {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(tint)

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func actionButtons(for seller: SellerProfile) -> some View {
        HStack(spacing: 10) {
            if seller.connectStatus == .pending || seller.connectStatus == .restricted
                || !seller.detailsSubmitted
            {
                PrimaryButton(
                    title: "Continue onboarding",
                    action: { Task { await viewModel.startSellerOnboarding() } },
                    paddingSize: 4,
                    isLoading: viewModel.isStartingOnboarding
                )
                .font(.caption.weight(.semibold))
            }

            Button {
                Task { await viewModel.refreshSellerStatus() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(.top, 2)
    }
}
