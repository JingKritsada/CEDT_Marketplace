import Combine
import SwiftUI

/// A "save for later" list. Each item is purchased individually via the per-row
/// "Buy Now" button — there is no bulk-checkout because each listing is a separate
/// PaymentIntent to its seller's Connect account (see PAYMENT_FLOW_GUIDE.md).
struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()

    @State private var showClearAlert = false
    @State private var showFilters = false
    @State private var pendingCheckout: Listing?
    @State private var searchText = ""
    @State private var selectedCategoryId: String? = nil
    @State private var categories: [Category] = []

    private let categoryService = CategoryService()
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading, viewModel.wishlist == nil {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else if let wishlist = viewModel.wishlist, !wishlist.items.isEmpty {
                        let items = filteredItems(from: wishlist)
                        if items.isEmpty {
                            EmptyStateView(
                                title: "No results",
                                message: "No items match your search or filter.",
                                systemImage: "magnifyingglass"
                            )
                            .frame(minHeight: 320)
                        } else {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Saved for later")
                                    .font(.title2.weight(.bold))
                                Spacer()
                                Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)

                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(items) { item in
                                    NavigationLink(
                                        destination: ListingDetailView(listingId: item.listing.id)
                                    ) {
                                        ListingCardView(listing: item.listing)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            Task { await viewModel.removeItem(listingId: item.listingId) }
                                        } label: {
                                            Label("Remove from Wishlist", systemImage: "heart.slash")
                                        }
                                        if isBuyable(item.listing) {
                                            Button {
                                                pendingCheckout = item.listing
                                            } label: {
                                                Label("Buy Now", systemImage: "bag.fill")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    } else {
                        EmptyStateView(
                            title: "Your wishlist is empty",
                            message: "Tap the heart on any listing to save it here for later.",
                            systemImage: "heart"
                        )
                        .frame(minHeight: 360)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .refreshable { await viewModel.load() }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .safeAreaInset(edge: .top) {
                SearchFilterBar(
                    placeholder: "Search wishlist…",
                    searchText: $searchText,
                    selectedCategoryId: $selectedCategoryId,
                    categories: categories,
                    onFilterTap: { showFilters = true },
                    onTrailingAction: viewModel.wishlist?.items.isEmpty == false
                        ? { showClearAlert = true } : nil
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
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
            .task {
                categories = await (try? categoryService.fetchCategories()) ?? []
                await viewModel.load()
            }
        }
        .background(Color(.systemGray6))
    }

    // MARK: - Derived data

    private func filteredItems(from wishlist: Wishlist) -> [WishlistItem] {
        wishlist.items.filter { item in
            // Match the home page: hide items that are no longer available.
            guard item.listing.status == .available else { return false }
            let matchesCategory =
                selectedCategoryId == nil || item.listing.category?.id == selectedCategoryId
            let matchesSearch =
                searchText.isEmpty
                    || item.listing.title.localizedCaseInsensitiveContains(searchText)
                    || item.listing.description.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    private func isBuyable(_ listing: Listing) -> Bool {
        listing.status == .available && !listing.isFree && listing.price > 0
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
