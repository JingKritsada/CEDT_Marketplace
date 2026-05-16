import SwiftUI

/// Reusable scrollable list of `ListingRowView` cards with a styled empty state.
/// Used by Posted / Purchased / Sold / Confirmed history views.
struct ListingHistoryListView: View {
    let listings: [Listing]
    let emptyTitle: String
    let emptyMessage: String
    let emptyIcon: String
    /// Optional per-row context-menu builder. Used by PostedItemsView to show an Edit action.
    var rowContextMenu: ((Listing) -> AnyView)?
    /// Optional per-row leading/trailing swipe actions (rendered to the trailing edge).
    var rowSwipeActions: ((Listing) -> AnyView)?

    var body: some View {
        Group {
            if listings.isEmpty {
                ScrollView(.vertical, showsIndicators: false) { emptyState }
            } else {
                // List (not LazyVStack) is required for `.swipeActions` to work. We hide all
                // List chrome — separators, default backgrounds, default insets — so the rows
                // look identical to the previous LazyVStack-of-cards layout.
                List {
                    ForEach(listings) { listing in
                        // ZStack trick: hidden NavigationLink + visible row content.
                        // Lets us suppress List's default trailing disclosure chevron so the
                        // ListingRowView's own chevron is the only one shown.
                        ZStack {
                            NavigationLink {
                                ListingDetailView(listingId: listing.id)
                            } label: {
                                EmptyView()
                            }
                            .opacity(0)

                            ListingRowView(listing: listing)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            if let rowContextMenu {
                                rowContextMenu(listing)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if let rowSwipeActions {
                                rowSwipeActions(listing)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color(.systemGray6))
    }

    private var emptyState: some View {
        EmptyStateView(title: emptyTitle, message: emptyMessage, systemImage: emptyIcon)
            .frame(minHeight: 400)
    }
}

#Preview {
    NavigationStack {
        ListingHistoryListView(
            listings: [
                Listing(
                    id: "1", sellerId: "s1", buyerId: nil,
                    title: "Raspberry Pi 4", description: "Used, good condition",
                    price: 900, isFree: false, status: .available, condition: .good,
                    courseCode: nil, categoryId: nil, pickupLocationId: nil,
                    images: ["https://picsum.photos/300"],
                    createdAt: Date(), updatedAt: Date(),
                    seller: nil, buyer: nil, category: Category(id: "1", name: "Electronics", slug: "electronics"),
                    pickupLocation: nil, reviews: nil
                ),
                Listing(
                    id: "2", sellerId: "s1", buyerId: nil,
                    title: "Arduino Uno", description: "Brand new",
                    price: 450, isFree: false, status: .sold, condition: .new,
                    courseCode: "2110101", categoryId: nil, pickupLocationId: nil,
                    images: [], createdAt: Date(), updatedAt: Date(),
                    seller: nil, buyer: nil, category: nil, pickupLocation: nil, reviews: nil
                )
            ],
            emptyTitle: "No items yet",
            emptyMessage: "Items will appear here.",
            emptyIcon: "tray"
        )
    }
}
