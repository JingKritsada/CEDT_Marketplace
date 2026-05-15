import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var showFilters = false
    @State private var categories: [Category] = []
    @State private var selectedCategoryId: String? = nil

    private let categoryService = CategoryService()
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else if viewModel.listings.isEmpty {
                        EmptyStateView(
                            title: "No listings",
                            message: "Try adjusting your filters or search.",
                            systemImage: "tray"
                        )
                        .frame(minHeight: 360)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(viewModel.listings) { listing in
                                NavigationLink(destination: ListingDetailView(listingId: listing.id)) {
                                    ListingCardView(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .refreshable { await viewModel.loadListings() }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .safeAreaInset(edge: .top) {
                SearchFilterBar(
                    placeholder: "Search components...",
                    searchText: $viewModel.searchText,
                    selectedCategoryId: $selectedCategoryId,
                    categories: categories,
                    onFilterTap: { showFilters = true },
                    onSubmit: { Task { await viewModel.searchListings() } },
                    allLabel: "All"
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
            .sheet(isPresented: $showFilters) {
                FilterModalView(activeQuery: $viewModel.activeQuery)
            }
            .onChange(of: selectedCategoryId) { _, newId in
                updateCategoryFilter(newId)
            }
            .onChange(of: viewModel.activeQuery) { _, newValue in
                selectedCategoryId = newValue?.categoryId
                Task { await viewModel.loadListings() }
            }
            .task {
                selectedCategoryId = viewModel.activeQuery?.categoryId
                categories = await (try? categoryService.fetchCategories()) ?? []
                await viewModel.loadListings()
            }
        }
    }

    private func updateCategoryFilter(_ categoryId: String?) {
        var query = viewModel.activeQuery ?? ListingQuery(status: .available)
        query.categoryId = categoryId
        query.status = query.status ?? .available
        viewModel.activeQuery = query
    }
}

#Preview {
    HomeView()
}
