import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.listings.isEmpty {
                    EmptyStateView(title: "No listings", message: "Try adjusting your filters or search.")
                } else {
                    List(viewModel.listings) { listing in
                        NavigationLink(destination: ListingDetailView(listingId: listing.id)) {
                            ListingRowView(listing: listing)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Marketplace")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filter") { showFilters = true }
                }
            }
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search) {
                Task { await viewModel.searchListings() }
            }
            .sheet(isPresented: $showFilters) {
                FilterModalView(activeQuery: $viewModel.activeQuery)
            }
            .onChange(of: viewModel.activeQuery) { _, _ in
                Task { await viewModel.loadListings() }
            }
            .task {
                await viewModel.loadListings()
            }
        }
    }
}
