import SwiftUI

struct PurchasedItemsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ListingHistoryListView(
            listings: viewModel.purchasedListings,
            emptyTitle: "No purchases yet",
            emptyMessage: "Items you've bought from other students\nwill appear here.",
            emptyIcon: "bag"
        )
        .navigationTitle("Purchased Items")
        .refreshable { await viewModel.loadProfile() }
    }
}
