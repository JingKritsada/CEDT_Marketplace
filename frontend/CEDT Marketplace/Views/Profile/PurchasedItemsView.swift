import SwiftUI

struct PurchasedItemsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ListingHistoryListView(
            listings: viewModel.purchasedListings,
            emptyTitle: "No purchases yet",
            emptyMessage: "Items you've bought from other students will appear here.",
            emptyIcon: "bag"
        )
        .navigationTitle("Purchased Items")
        .task { await viewModel.loadProfile() }
        .refreshable { await viewModel.loadProfile() }
    }
}
