import Combine
import SwiftUI

/// A "save for later" list. Each item is purchased individually via the per-row
/// "Buy Now" button — there is no bulk-checkout because each listing is a separate
/// PaymentIntent to its seller's Connect account (see PAYMENT_FLOW_GUIDE.md).
struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()

    @State private var showClearAlert = false
    @State private var pendingCheckout: Listing?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading, viewModel.wishlist == nil {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let wishlist = viewModel.wishlist, !wishlist.items.isEmpty {
                    contentList(wishlist)
                } else {
                    emptyState
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Wishlist")
            .toolbar {
                if let wishlist = viewModel.wishlist, !wishlist.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") { showClearAlert = true }
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .navigationDestination(item: $pendingCheckout) { listing in
                CheckoutView(directListing: listing)
            }
            .alert("Clear wishlist?", isPresented: $showClearAlert) {
                Button("Clear", role: .destructive) {
                    Task { await viewModel.clear() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes every saved item. You can save them again from any listing.")
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
        .background(Color(.systemGray6))
    }

    // MARK: - Content

    private func contentList(_ wishlist: Wishlist) -> some View {
        List {
            Section {
                HStack(alignment: .firstTextBaseline) {
                    Text("Saved for later")
                        .font(.title2.weight(.bold))
                    Spacer()
                    Text("\(wishlist.items.count) item\(wishlist.items.count == 1 ? "" : "s")")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 0, trailing: 4))
            }

            Section {
                ForEach(wishlist.items) { item in
                    wishlistRow(item)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeItem(listingId: item.listingId) }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }

    private func wishlistRow(_ item: WishlistItem) -> some View {
        VStack(spacing: 0) {
            NavigationLink {
                ListingDetailView(listingId: item.listing.id)
            } label: {
                ListingRowView(listing: item.listing)
            }
            .buttonStyle(.plain)

            if isBuyable(item.listing) {
                Divider()
                    .padding(.horizontal, 12)

                Button {
                    pendingCheckout = item.listing
                } label: {
                    HStack(spacing: 6) {
                        Spacer()
                        Image(systemName: "bag.fill")
                            .font(.caption.weight(.bold))
                        Text("Buy Now")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundColor(.accentPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func isBuyable(_ listing: Listing) -> Bool {
        listing.status == .available && !listing.isFree && listing.price > 0
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 56, weight: .regular))
                .foregroundColor(.accentPrimary.opacity(0.6))
                .padding(20)
                .background(Circle().fill(Color(.systemBackground)))

            VStack(spacing: 6) {
                Text("Your wishlist is empty")
                    .font(.title3.weight(.semibold))
                Text("Tap the heart on any listing \nto save it here for later.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}

extension Listing: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    WishlistView()
}
