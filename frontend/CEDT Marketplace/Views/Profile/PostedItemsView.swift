import SwiftUI

struct PostedItemsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var editingListing: Listing?
    @State private var pendingDeletion: Listing?

    var body: some View {
        ListingHistoryListView(
            listings: viewModel.postedListings,
            emptyTitle: "No posted items yet",
            emptyMessage: "Items you list for sale will show up here.",
            emptyIcon: "tag",
            rowContextMenu: { listing in
                AnyView(
                    Group {
                        Button {
                            editingListing = listing
                        } label: {
                            Label("Edit listing", systemImage: "square.and.pencil")
                        }
                        Button(role: .destructive) {
                            pendingDeletion = listing
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                )
            },
            rowSwipeActions: { listing in
                AnyView(
                    Group {
                        Button {
                            editingListing = listing
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.accentColor)

                        Button(role: .destructive) {
                            pendingDeletion = listing
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                )
            }
        )
        .navigationTitle("Posted Items")
        .refreshable { await viewModel.loadProfile() }
        .sheet(item: $editingListing, onDismiss: {
            Task { await viewModel.loadProfile() }
        }) { listing in
            PostItemView(editingListing: listing)
        }
        .alert(
            "Delete this listing?",
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            presenting: pendingDeletion
        ) { listing in
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteListing(id: listing.id)
                    if success {
                        LocalNotifier.success("Listing removed.", title: "Deleted")
                    } else {
                        LocalNotifier.error(
                            viewModel.errorMessage ?? "Couldn't delete this listing.",
                            title: "Delete failed"
                        )
                    }
                    pendingDeletion = nil
                }
            }
            Button("Cancel", role: .cancel) { pendingDeletion = nil }
        } message: { listing in
            Text("“\(listing.title)” will be permanently removed from the marketplace.")
        }
    }
}

#Preview {
    NavigationStack {
        PostedItemsView(viewModel: ProfileViewModel())
    }
}
