import Combine
import SwiftUI

/// Single-listing checkout. Reached from any listing's Purchase button or from
/// the Wishlist's Buy Now row action.
struct CheckoutView: View {
    let directListing: Listing

    @StateObject private var viewModel = CheckoutViewModel()

    @Environment(\.dismiss) private var dismiss

    private let cardCornerRadius: CGFloat = 24

    init(directListing: Listing) {
        self.directListing = directListing
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                orderSummaryCard

                pickupInfoCard

                priceBreakdownCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            confirmBar
        }
        .background(
            PaymentSheetPresenter(
                isActive: $viewModel.isPaymentSheetActive,
                clientSecret: viewModel.checkoutResponse?.clientSecret,
                publishableKey: viewModel.checkoutResponse?.publishableKey,
                onCompletion: viewModel.handlePaymentOutcome
            )
        )
        .task {
            viewModel.configure(with: directListing)
        }
        .onChange(of: viewModel.paymentOutcome) { _, outcome in
            guard let outcome else { return }
            switch outcome {
            case .succeeded:
                LocalNotifier.success(
                    "Meet the seller at the pickup spot. Funds release once you tap Confirm Receipt.",
                    title: "Order paid"
                )
                viewModel.paymentOutcome = nil
                dismiss()
            case .canceled:
                viewModel.paymentOutcome = nil
            case let .failed(message):
                LocalNotifier.error(message, title: "Payment failed")
                viewModel.paymentOutcome = nil
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            guard let message = newValue, !message.isEmpty else { return }
            LocalNotifier.error(message)
            viewModel.errorMessage = nil
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review your order")
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Text("Confirm the item and pickup location set by the seller.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 2)
    }

    // MARK: - Order

    private var orderSummaryCard: some View {
        card(title: "Item", systemImage: "bag") {
            compactItemRow(viewModel.listing ?? directListing)
        }
    }

    private func compactItemRow(_ listing: Listing) -> some View {
        HStack(spacing: 12) {
            thumbnail(for: listing)

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                if let category = listing.category?.name {
                    Text(category)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 8)

            Text(listing.isFree ? "Free" : "฿\(listing.price)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.accentPrimary)
        }
    }

    @ViewBuilder
    private func thumbnail(for listing: Listing) -> some View {
        let trimmed =
            listing.images.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        Group {
            if !trimmed.isEmpty,
               let url = URL(string: trimmed),
               url.scheme?.hasPrefix("http") == true
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image.resizable().scaledToFill()
                    case .empty:
                        ZStack {
                            Color(.systemGray5)
                            ProgressView().tint(.gray)
                        }
                    default:
                        ZStack {
                            Color(.systemGray5)
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                    }
                }
            } else {
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Pickup info (read-only)

    private var pickupInfoCard: some View {
        card(title: "Pickup location", systemImage: "mappin.and.ellipse") {
            if let location = viewModel.pickupLocation {
                pickupLocationRow(location)
                Text("Meet the seller at this spot after the order is confirmed.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            } else {
                Text("The seller has not set a pickup spot for this item yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func pickupLocationRow(_ location: PickupLocation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "mappin")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text(location.building)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let description = location.description, !description.isEmpty {
                    Text(description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Summary

    private var priceBreakdownCard: some View {
        card(title: "Summary", systemImage: "bahtsign.circle") {
            VStack(spacing: 10) {
                breakdownRow(label: "Item", value: "฿\(viewModel.subtotal)")
                breakdownRow(
                    label: "Service fee", value: "Included", valueColor: .secondary
                )

                Divider()

                breakdownRow(
                    label: "Total", value: "฿\(viewModel.subtotal)", isEmphasis: true
                )
            }
        }
    }

    private func breakdownRow(
        label: String, value: String, valueColor: Color = .primary, isEmphasis: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(isEmphasis ? .subheadline.weight(.semibold) : .subheadline)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(isEmphasis ? .title3.weight(.bold) : .subheadline.weight(.medium))
                .foregroundColor(isEmphasis ? .accentPrimary : valueColor)
        }
    }

    // MARK: - Confirm

    private var confirmBar: some View {
        VStack(spacing: 0) {
            PrimaryButton(
                title: viewModel.subtotal == 0 ? "Free — confirm" : "Pay with card",
                action: {
                    Task { await viewModel.startCheckout() }
                },
                paddingSize: 10,
                isLoading: viewModel.isLoading || viewModel.isPaymentSheetActive
            )
            .font(.headline.weight(.semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func card(
        title: String, systemImage: String, @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.primary)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}
