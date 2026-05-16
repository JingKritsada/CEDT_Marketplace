import Combine
import Foundation

@MainActor
final class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var sellerProfile: UserProfile?
    @Published var buyerProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAddedToWishlist = false

    private let listingService: ListingService
    private let wishlistService: WishlistService
    private let userService: UserService
    private let reviewService: ReviewService

    init(
        listingService: ListingService? = nil,
        wishlistService: WishlistService? = nil,
        userService: UserService? = nil,
        reviewService: ReviewService? = nil
    ) {
        self.listingService = listingService ?? ListingService()
        self.wishlistService = wishlistService ?? WishlistService()
        self.userService = userService ?? UserService()
        self.reviewService = reviewService ?? ReviewService()
    }

    /// Submits a 1–5 star review with optional comment. After success the listing
    /// transitions to `.rated` server-side, so we reload to refresh the UI state.
    func submitReview(rating: Int, comment: String?) async -> Bool {
        guard let listing else { return false }
        do {
            _ = try await reviewService.createReview(
                CreateReviewRequest(
                    listingId: listing.id,
                    rating: rating,
                    comment: comment?.isEmpty == true ? nil : comment
                )
            )
            await loadListing(id: listing.id)
            return true
        } catch let error as NetworkError {
            errorMessage = error.userMessage
            return false
        } catch {
            errorMessage = NetworkError.unknown.userMessage
            return false
        }
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

    func addToWishlist() async -> Bool {
        guard let listing else { return false }
        do {
            _ = try await wishlistService.addItem(listingId: listing.id)
            isAddedToWishlist = true
            return true
        } catch let error as NetworkError {
            errorMessage = error.userMessage
            return false
        } catch {
            errorMessage = NetworkError.unknown.userMessage
            return false
        }
    }

    private func loadRelatedProfilesIfNeeded() async {
        guard let listing else { return }

        if needsSocialLinks(listing.seller),
           let sellerId = listing.sellerId ?? listing.seller?.id,
           !sellerId.isEmpty
        {
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
