import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var showFilters = false
    @State private var categories: [Category] = []
    @State private var selectedCategoryId: String? = nil
    @State private var categoriesLoadFailed = false

    private let categoryService = CategoryService()
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
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
                        EmptyStateView(title: "No listings", message: "Try adjusting your filters or search.")
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
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .safeAreaInset(edge: .top) {
                searchBar()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
            }
            .sheet(isPresented: $showFilters) {
                FilterModalView(activeQuery: $viewModel.activeQuery)
            }
            .onChange(of: viewModel.activeQuery) { _, newValue in
                selectedCategoryId = newValue?.categoryId
                Task { await viewModel.loadListings() }
            }
            .task {
                selectedCategoryId = viewModel.activeQuery?.categoryId
                do {
                    categories = try await categoryService.fetchCategories()
                    categoriesLoadFailed = false
                } catch {
                    categories = []
                    categoriesLoadFailed = true
                }
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

    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func searchBar() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)

                    TextField("Search components...", text: $viewModel.searchText)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.searchListings() }
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button {
                    showFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }

            if !categoriesLoadFailed {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        categoryChip(title: "All Items", isSelected: selectedCategoryId == nil) {
                            updateCategoryFilter(nil)
                        }
                        ForEach(categories) { category in
                            categoryChip(title: category.name, isSelected: selectedCategoryId == category.id) {
                                updateCategoryFilter(category.id)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
