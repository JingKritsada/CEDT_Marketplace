import SwiftUI

struct ConfirmedItemsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ListingHistoryListView(
            listings: viewModel.confirmedListings,
            emptyTitle: "No items in transit",
            emptyMessage: "Items waiting for pickup or already handed over\nwill show up here.",
            emptyIcon: "shippingbox"
        )
        .navigationTitle("Confirmed Items")
        .refreshable { await viewModel.loadProfile() }
    }
}
