import SwiftUI

struct SoldItemsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ListingHistoryListView(
            listings: viewModel.soldListings,
            emptyTitle: "No sold items yet",
            emptyMessage: "Once a buyer confirms receipt, those items will show up here.",
            emptyIcon: "checkmark.seal"
        )
        .navigationTitle("Sold Items")
        .task { await viewModel.loadProfile() }
        .refreshable { await viewModel.loadProfile() }
    }
}
