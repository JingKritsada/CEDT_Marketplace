import Foundation

enum Endpoint {
    case login
    case register
    case listings(query: ListingQuery?)
    case listingDetail(id: String)
    case createListing
    case updateListing(id: String)
    case deleteListing(id: String)
    case confirmReceived(id: String)
    case claimFreeListing(id: String)
    case uploadImages
    case search(query: ListingQuery?)
    case categories
    case pickupLocations
    case me
    case user(id: String)
    case updateProfile
    case wishlist
    case addToWishlist
    case removeFromWishlist(listingId: String)
    case clearWishlist
    case reviewsByListing(listingId: String)
    case reviewsBySeller(sellerId: String)
    case createReview
    case refreshToken
    case logout
    case appleLogin

    // Stripe / payments
    case checkout
    case payments
    case paymentDetail(id: String)
    case cancelPayment(id: String)
    case refundPayment(id: String)
    case sellerOnboarding
    case sellerOnboardingRefresh
    case sellerMe
    case sellerBalance
    case sellerPayouts

    var method: HTTPMethod {
        switch self {
        case .login,
             .register,
             .createListing,
             .confirmReceived,
             .claimFreeListing,
             .uploadImages,
             .addToWishlist,
             .createReview,
             .refreshToken,
             .logout,
             .appleLogin,
             .checkout,
             .cancelPayment,
             .refundPayment,
             .sellerOnboarding,
             .sellerOnboardingRefresh:
            .post
        case .updateListing, .updateProfile:
            .patch
        case .deleteListing, .removeFromWishlist, .clearWishlist:
            .delete
        case .listings,
             .listingDetail,
             .search,
             .categories,
             .pickupLocations,
             .me,
             .user,
             .wishlist,
             .reviewsByListing,
             .reviewsBySeller,
             .payments,
             .paymentDetail,
             .sellerMe,
             .sellerBalance,
             .sellerPayouts:
            .get
        }
    }

    var path: String {
        switch self {
        case .login:
            "/auth/login"
        case .register:
            "/auth/register"
        case .refreshToken:
            "/auth/refresh"
        case .logout:
            "/auth/logout"
        case .appleLogin:
            "/auth/social/apple"
        case .listings:
            "/listings"
        case .search:
            "/listings/search"
        case let .listingDetail(id):
            "/listings/\(id)"
        case .createListing:
            "/listings"
        case let .updateListing(id):
            "/listings/\(id)"
        case let .deleteListing(id):
            "/listings/\(id)"
        case let .confirmReceived(id):
            "/listings/\(id)/confirm-received"
        case let .claimFreeListing(id):
            "/listings/\(id)/claim-free"
        case .uploadImages:
            "/uploads/images"
        case .categories:
            "/categories"
        case .pickupLocations:
            "/pickup-locations"
        case .me:
            "/users/me"
        case let .user(id):
            "/users/\(id)"
        case .updateProfile:
            "/users/me"
        case .wishlist:
            "/wishlist"
        case .addToWishlist:
            "/wishlist/items"
        case let .removeFromWishlist(listingId):
            "/wishlist/items/\(listingId)"
        case .clearWishlist:
            "/wishlist/clear"
        case .reviewsByListing:
            "/reviews"
        case .reviewsBySeller:
            "/reviews"
        case .createReview:
            "/reviews"
        case .checkout:
            "/checkout"
        case .payments:
            "/payments"
        case let .paymentDetail(id):
            "/payments/\(id)"
        case let .cancelPayment(id):
            "/payments/\(id)/cancel"
        case let .refundPayment(id):
            "/payments/\(id)/refund"
        case .sellerOnboarding:
            "/sellers/onboarding"
        case .sellerOnboardingRefresh:
            "/sellers/onboarding/refresh"
        case .sellerMe:
            "/sellers/me"
        case .sellerBalance:
            "/sellers/me/balance"
        case .sellerPayouts:
            "/sellers/me/payouts"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login,
             .register,
             .refreshToken,
             .logout,
             .appleLogin,
             .listings,
             .listingDetail,
             .search,
             .categories,
             .pickupLocations,
             .reviewsByListing,
             .reviewsBySeller:
            false
        case .createListing,
             .updateListing,
             .deleteListing,
             .confirmReceived,
             .claimFreeListing,
             .uploadImages,
             .me,
             .updateProfile,
             .wishlist,
             .addToWishlist,
             .removeFromWishlist,
             .clearWishlist,
             .createReview,
             .checkout,
             .payments,
             .paymentDetail,
             .cancelPayment,
             .refundPayment,
             .sellerOnboarding,
             .sellerOnboardingRefresh,
             .sellerMe,
             .sellerBalance,
             .sellerPayouts:
            true
        case .user:
            false
        }
    }

    func url(baseURL: URL) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = path

        switch self {
        case let .listings(query), let .search(query):
            components?.queryItems = query?.toQueryItems()
        case let .reviewsByListing(listingId):
            components?.queryItems = [URLQueryItem(name: "listingId", value: listingId)]
        case let .reviewsBySeller(sellerId):
            components?.queryItems = [URLQueryItem(name: "sellerId", value: sellerId)]
        default:
            break
        }

        return components?.url
    }
}
