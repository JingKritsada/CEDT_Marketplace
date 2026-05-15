import Combine
import SwiftUI
import UIKit
import UserNotifications

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

struct ListingDetailView: View {
    let listingId: String

    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = ListingDetailViewModel()
    @State private var showCheckout = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []
    @State private var showConfirmReceiptAlert = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                if let listing = viewModel.listing {
                    listingDetailContent(listing)
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .scaleEffect(1.5)
                } else {
                    EmptyStateView(title: "No listings", message: "Try refreshing or check back later.")
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
        .navigationTitle("Details")
        .navigationDestination(isPresented: $showCheckout) {
            if let listing = viewModel.listing {
                CheckoutView(directListing: listing)
            }
        }
        .sheet(isPresented: $showShare) {
            ActivityView(activityItems: shareItems)
                .presentationDetents([.medium])
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .task {
            await viewModel.loadListing(id: listingId)
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            guard let message = newValue, !message.isEmpty else { return }
            LocalNotifier.error(message)
            viewModel.errorMessage = nil
        }
    }

    private func listingDetailContent(_ listing: Listing) -> some View {
        VStack(spacing: 16) {
            heroSection(listing)
            overviewSection(listing)
            detailsSection(listing)
            peopleSection(listing)
            pickupSection(listing)
            reviewsSection(listing)
        }
    }

    private func heroSection(_ listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                ImageCarousel(imageUrls: listing.images)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                HStack {
                    StatusBadge(status: listing.status)
                        .padding(12)

                    Spacer()

                    Text(listing.isFree ? "Free" : "THB \(listing.price)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.regularMaterial)
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                        .padding(12)
                }
            }

            HStack(spacing: 8) {
                Label(
                    "\(listing.images.count) image\(listing.images.count == 1 ? "" : "s")",
                    systemImage: "photo.on.rectangle.angled"
                )
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func overviewSection(_ listing: Listing) -> some View {
        detailSection(title: "Overview", systemImage: "info.circle") {
            VStack(alignment: .leading, spacing: 12) {
                Text(listing.title)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)

                Text(listing.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()

                VStack(spacing: 10) {
                    detailRow(
                        icon: "tag", title: "Price", value: listing.isFree ? "Free" : "THB \(listing.price)"
                    )
                    detailRow(icon: "checkmark.seal", title: "Status", value: listing.status.displayName)
                    detailRow(
                        icon: "sparkles", title: "Condition",
                        value: listing.condition?.displayName ?? "Not specified"
                    )
                }
            }
        }
    }

    private func detailsSection(_ listing: Listing) -> some View {
        detailSection(title: "Listing Details", systemImage: "square.grid.2x2") {
            VStack(spacing: 10) {
                detailRow(
                    icon: "book.closed", title: "Course", value: listing.courseCode ?? "Not specified"
                )
                detailRow(
                    icon: "rectangle.grid.1x2", title: "Category",
                    value: listing.category?.name ?? "Not specified"
                )
                detailRow(
                    icon: "calendar", title: "Created",
                    value: listing.createdAt?.toShortString() ?? "Not available"
                )
                detailRow(
                    icon: "arrow.clockwise", title: "Updated",
                    value: listing.updatedAt?.toShortString() ?? "Not available"
                )
            }
        }
    }

    private func peopleSection(_ listing: Listing) -> some View {
        detailSection(title: "People", systemImage: "person.2") {
            VStack(spacing: 12) {
                if let seller = listing.seller {
                    profileRow(
                        title: "Seller",
                        name: seller.displayName,
                        avatarUrl: seller.avatarUrl
                    )
                    socialLinksRow(
                        lineId: seller.lineId ?? viewModel.sellerProfile?.lineId,
                        instagram: seller.instagram ?? viewModel.sellerProfile?.instagram,
                        facebookUrl: seller.facebookUrl ?? viewModel.sellerProfile?.facebookUrl
                    )
                } else {
                    detailRow(icon: "person", title: "Seller", value: listing.sellerId ?? "Not available")
                }

                if let buyer = listing.buyer {
                    Divider()
                    profileRow(
                        title: "Buyer",
                        name: buyer.displayName,
                        avatarUrl: buyer.avatarUrl
                    )

                    socialLinksRow(
                        lineId: buyer.lineId ?? viewModel.buyerProfile?.lineId,
                        instagram: buyer.instagram ?? viewModel.buyerProfile?.instagram,
                        facebookUrl: buyer.facebookUrl ?? viewModel.buyerProfile?.facebookUrl
                    )
                } else if let buyerId = listing.buyerId {
                    Divider()
                    detailRow(icon: "person.fill", title: "Buyer", value: buyerId)
                }
            }
        }
    }

    private func pickupSection(_ listing: Listing) -> some View {
        detailSection(title: "Pickup", systemImage: "mappin.and.ellipse") {
            VStack(spacing: 10) {
                if let pickupLocation = listing.pickupLocation {
                    detailRow(icon: "mappin", title: "Location", value: pickupLocation.name)
                    detailRow(icon: "building.2", title: "Building", value: pickupLocation.building)

                    if let description = pickupLocation.description, !description.isEmpty {
                        detailRow(icon: "text.alignleft", title: "Note", value: description)
                    }
                } else {
                    detailRow(
                        icon: "mappin", title: "Pickup Location",
                        value: listing.pickupLocationId ?? "Not available"
                    )
                }
            }
        }
    }

    private func reviewsSection(_ listing: Listing) -> some View {
        guard let reviews = listing.reviews, !reviews.isEmpty else {
            return AnyView(EmptyView())
        }

        let averageRating = Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)

        return AnyView(
            detailSection(title: "Reviews", systemImage: "star.bubble") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 10) {
                        RatingStarsView(rating: averageRating)
                        Text(String(format: "%.1f", averageRating))
                            .font(.headline)
                        Text("(\(reviews.count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    VStack(spacing: 12) {
                        ForEach(reviews.prefix(3)) { review in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(review.reviewer?.displayName ?? "Anonymous")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    RatingStarsView(rating: Double(review.rating))
                                }

                                if let comment = review.comment, !comment.isEmpty {
                                    Text(comment)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                if let createdAt = review.createdAt {
                                    Text(createdAt.toShortString())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        )
    }

    private func detailSection(
        title: String, systemImage: String, @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.primary)

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundColor(.accentPrimary)
                .frame(width: 18)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func profileRow(title: String, name: String, avatarUrl: String?) -> some View {
        HStack(spacing: 12) {
            profileAvatar(name: name, avatarUrl: avatarUrl)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func socialLinksRow(lineId: String?, instagram: String?, facebookUrl: String?)
        -> some View
    {
        let links = socialLinks(lineId: lineId, instagram: instagram, facebookUrl: facebookUrl)

        if !links.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(links) { link in
                    socialLinkView(link)
                }
            }
            .padding(.top, 6)
        }
    }

    @ViewBuilder
    private func socialLinkView(_ link: SocialLink) -> some View {
        if let url = link.url {
            Link(destination: url) {
                socialLinkLabel(link)
            }
        } else {
            socialLinkLabel(link)
        }
    }

    private func socialLinkLabel(_ link: SocialLink) -> some View {
        HStack(spacing: 12) {
            Image(systemName: link.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundColor(link.color)

            Text(link.value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .textSelection(.enabled)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(link.color.opacity(0.12))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func socialLinks(lineId: String?, instagram: String?, facebookUrl: String?)
        -> [SocialLink]
    {
        var links: [SocialLink] = []

        if let lineId = lineId?.trimmingCharacters(in: .whitespacesAndNewlines), !lineId.isEmpty {
            let line = "https://line.me/ti/p/~\(lineId)"
            let url = URL(string: line)
            links.append(
                SocialLink(systemImage: "message.fill", title: "LINE", value: line, url: url, color: .green)
            )
        }

        if let instagram = instagram?.trimmingCharacters(in: .whitespacesAndNewlines),
           !instagram.isEmpty
        {
            let url = URL(string: instagram)
            links.append(
                SocialLink(
                    systemImage: "camera.fill", title: "Instagram", value: instagram, url: url, color: .pink
                )
            )
        }

        if let facebookUrl = facebookUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
           !facebookUrl.isEmpty
        {
            let url = URL(string: facebookUrl)
            links.append(
                SocialLink(
                    systemImage: "f.circle.fill", title: "Facebook", value: facebookUrl, url: url,
                    color: .blue
                )
            )
        }

        return links
    }

    private func profileAvatar(name: String, avatarUrl: String?) -> some View {
        Group {
            if let avatarUrl,
               let url = URL(string: avatarUrl.trimmingCharacters(in: .whitespacesAndNewlines)),
               url.scheme?.hasPrefix("http") == true
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        initialsAvatar(name)
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.15)
                            ProgressView()
                        }
                    @unknown default:
                        initialsAvatar(name)
                    }
                }
            } else {
                initialsAvatar(name)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }

    private func initialsAvatar(_ name: String) -> some View {
        ZStack {
            Color.accentPrimary.opacity(0.12)
            Text(initials(from: name))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.accentPrimary)
        }
    }

    private func initials(from name: String) -> String {
        let pieces = name.split(separator: " ").prefix(2)
        let letters = pieces.compactMap(\.first).map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    private struct SocialLink: Identifiable {
        let systemImage: String
        let title: String
        let value: String
        let url: URL?
        let color: Color

        var id: String {
            title + value
        }
    }

    private var shareURL: URL? {
        guard let images = viewModel.listing?.images else { return nil }

        for rawUrl in images {
            let trimmed = rawUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(),
                  scheme == "http" || scheme == "https" else
            {
                continue
            }
            return url
        }

        return nil
    }

    private var shareButton: some View {
        Button {
            guard let url = shareURL else {
                LocalNotifier.error("No image or invalid URL.", title: "Unable to share")
                return
            }

            shareItems = [url]
            showShare = true
        } label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.primary)
        }
    }

    private var bottomActionBar: some View {
        Group {
            if shouldShowConfirmReceipt {
                confirmReceiptButton
            } else if !isCurrentUserSeller {
                HStack(spacing: 12) {
                    addToWishlistButton
                    purchaseButton
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
        .alert("Confirm receipt?", isPresented: $showConfirmReceiptAlert) {
            Button("Confirm", role: .none) {
                Task {
                    await viewModel.confirmReceived()
                    if viewModel.errorMessage == nil {
                        LocalNotifier.success(
                            "Funds have been released to the seller.", title: "Receipt confirmed"
                        )
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "Confirming releases payment to the seller. Only confirm after you've physically received the item."
            )
        }
    }

    private var currentUserId: String? {
        session.currentUser?.id
    }

    private var isCurrentUserSeller: Bool {
        guard let listing = viewModel.listing, let currentUserId else { return false }
        return listing.sellerId == currentUserId
    }

    private var shouldShowConfirmReceipt: Bool {
        guard let listing = viewModel.listing, let currentUserId else { return false }
        guard listing.buyerId == currentUserId else { return false }
        return [.paid, .sent, .waitingForPickup].contains(listing.status)
    }

    private var confirmReceiptButton: some View {
        PrimaryButton(
            title: "Confirm Receipt",
            action: { showConfirmReceiptAlert = true },
            paddingSize: 8,
            isLoading: viewModel.isLoading
        )
        .font(.title3.weight(.semibold))
        .frame(maxWidth: .infinity)
    }

    private var addToWishlistButton: some View {
        Button {
            Task {
                let success = await viewModel.addToWishlist()
                if success {
                    LocalNotifier.success(
                        "We saved this item so you can buy it later.", title: "Saved to wishlist"
                    )
                }
                // Failure path: errorMessage is set by the view model and the
                // root .onChange below surfaces it as a single notification.
            }
        } label: {
            Image(systemName: viewModel.isAddedToWishlist ? "heart.fill" : "heart")
                .font(.title3.weight(.semibold))
                .foregroundColor(viewModel.isAddedToWishlist ? .secondary : .accentPrimary)
                .padding(8)
        }
        .buttonStyle(.bordered)
        .tint(viewModel.isAddedToWishlist ? .secondary : .accentPrimary)
        .font(.title3.weight(.semibold))
        .disabled(viewModel.isAddedToWishlist)
    }

    private var purchaseButton: some View {
        PrimaryButton(
            title: "Purchase",
            action: {
                if viewModel.listing != nil {
                    showCheckout = true
                }
            },
            paddingSize: 8,
            isLoading: viewModel.isLoading
        )
        .font(.title3.weight(.semibold))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(listingId: "test-01")
    }
}
