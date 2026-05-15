import SwiftUI

/// Reusable scrollable list of `ListingRowView` cards with a styled empty state.
/// Used by Posted / Purchased / Sold / Confirmed history views.
struct ListingHistoryListView: View {
    let listings: [Listing]
    let emptyTitle: String
    let emptyMessage: String
    let emptyIcon: String

    var body: some View {
        Group {
            if listings.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
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
        }
        .background(Color(.systemGray6))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyIcon)
                .font(.system(size: 48, weight: .regular))
                .foregroundColor(.accentPrimary.opacity(0.6))
                .padding(18)
                .background(Circle().fill(Color.white))

            VStack(spacing: 6) {
                Text(emptyTitle)
                    .font(.title3.weight(.semibold))
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
