import SwiftUI

/// Reusable scrollable list of `ListingRowView` cards with a styled empty state.
/// Used by Posted / Purchased / Sold / Confirmed history views.
struct ListingHistoryListView: View {
    let listings: [Listing]
    let emptyTitle: String
    let emptyMessage: String
    let emptyIcon: String

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if listings.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(listings) { listing in
                        NavigationLink {
                            ListingDetailView(listingId: listing.id)
                        } label: {
                            ListingRowView(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemGray6))
    }

    private var emptyState: some View {
        EmptyStateView(title: emptyTitle, message: emptyMessage, systemImage: emptyIcon)
            .frame(minHeight: 400)
    }
}
