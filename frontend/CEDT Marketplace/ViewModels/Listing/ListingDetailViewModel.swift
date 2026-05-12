import Combine
import Foundation

@MainActor
final class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let listingService: ListingService
    private let cartService: CartService

    init(listingService: ListingService? = nil, cartService: CartService? = nil) {
        self.listingService = listingService ?? ListingService()
        self.cartService = cartService ?? CartService()
    }

    func loadListing(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            listing = try await listingService.listingDetail(id: id)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func confirmReceived() async {
        guard let listing else { return }
        do {
            self.listing = try await listingService.confirmReceived(id: listing.id)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func addToCart() async {
        guard let listing else { return }
        do {
            _ = try await cartService.addItem(listingId: listing.id)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }
}
