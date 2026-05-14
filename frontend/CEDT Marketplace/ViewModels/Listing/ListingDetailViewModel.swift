import Combine
import Foundation

@MainActor
final class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var sellerProfile: UserProfile?
    @Published var buyerProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let listingService: ListingService
    private let cartService: CartService
    private let userService: UserService

    init(listingService: ListingService? = nil, cartService: CartService? = nil, userService: UserService? = nil) {
        self.listingService = listingService ?? ListingService()
        self.cartService = cartService ?? CartService()
        self.userService = userService ?? UserService()
    }

    func loadListing(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            listing = try await listingService.listingDetail(id: id)
            await loadRelatedProfilesIfNeeded()
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

    private func loadRelatedProfilesIfNeeded() async {
        guard let listing else { return }

        if needsSocialLinks(listing.seller), let sellerId = listing.sellerId ?? listing.seller?.id, !sellerId.isEmpty {
            sellerProfile = try? await userService.getUser(id: sellerId)
        }

        if let buyerId = listing.buyerId, !buyerId.isEmpty, needsSocialLinks(listing.buyer) {
            buyerProfile = try? await userService.getUser(id: buyerId)
        }
    }

    private func needsSocialLinks(_ summary: UserSummary?) -> Bool {
        guard let summary else { return true }
        return summary.lineId == nil || summary.instagram == nil || summary.facebookUrl == nil
    }
}
