import Combine
import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    @Published var cart: Cart?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let cartService: CartService

    init(cartService: CartService? = nil) {
        self.cartService = cartService ?? CartService()
    }

    func loadCart() async {
        isLoading = true
        defer { isLoading = false }
        do {
            cart = try await cartService.fetchCart()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func removeItem(listingId: String) async {
        do {
            try await cartService.removeItem(listingId: listingId)
            await loadCart()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func clearCart() async {
        do {
            try await cartService.clearCart()
            cart = nil
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }
}
