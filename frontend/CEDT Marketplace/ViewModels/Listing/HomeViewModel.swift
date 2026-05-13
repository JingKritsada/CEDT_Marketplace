import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var activeQuery: ListingQuery? = ListingQuery(status: .available)

    private let listingService: ListingService

    init(listingService: ListingService? = nil) {
        self.listingService = listingService ?? ListingService()
    }

    func loadListings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            listings = try await listingService.fetchListings(query: activeQuery)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func searchListings() async {
        var query = activeQuery ?? ListingQuery(status: .available)
        query.search = searchText.isEmpty ? nil : searchText
        activeQuery = query
        await loadListings()
    }
}
