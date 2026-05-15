import Combine
import Foundation

@MainActor
final class WishlistViewModel: ObservableObject {
    @Published var wishlist: Wishlist?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: WishlistService

    init(service: WishlistService? = nil) {
        self.service = service ?? WishlistService()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            wishlist = try await service.fetchWishlist()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func removeItem(listingId: String) async {
        do {
            try await service.removeItem(listingId: listingId)
            await load()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func clear() async {
        do {
            try await service.clearWishlist()
            wishlist = nil
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }
}
