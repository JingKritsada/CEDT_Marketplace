import SwiftUI

struct PostedItemsView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ListingHistoryListView(
            listings: viewModel.postedListings,
            emptyTitle: "No posted items yet",
            emptyMessage: "Items you list for sale will show up here.",
            emptyIcon: "tag"
        )
        .navigationTitle("Posted Items")
        .task { await viewModel.loadProfile() }
        .refreshable { await viewModel.loadProfile() }
    }
}
