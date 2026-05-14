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
    case uploadImages
    case search(query: ListingQuery?)
    case categories
    case pickupLocations
    case me
    case user(id: String)
    case updateProfile
    case cart
    case addToCart
    case removeFromCart(listingId: String)
    case clearCart
    case reviewsByListing(listingId: String)
    case reviewsBySeller(sellerId: String)
    case createReview
    case refreshToken
    case logout

    var method: HTTPMethod {
        switch self {
        case .login, .register, .createListing, .confirmReceived, .uploadImages, .addToCart, .createReview, .refreshToken, .logout:
            return .post
        case .updateListing, .updateProfile:
            return .patch
        case .deleteListing, .removeFromCart, .clearCart:
            return .delete
        case .listings, .listingDetail, .search, .categories, .pickupLocations, .me, .user, .cart, .reviewsByListing, .reviewsBySeller:
            return .get
        }
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .refreshToken:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        case .listings:
            return "/listings"
        case .search:
            return "/listings/search"
        case let .listingDetail(id):
            return "/listings/\(id)"
        case .createListing:
            return "/listings"
        case let .updateListing(id):
            return "/listings/\(id)"
        case let .deleteListing(id):
            return "/listings/\(id)"
        case let .confirmReceived(id):
            return "/listings/\(id)/confirm-received"
        case .uploadImages:
            return "/uploads/images"
        case .categories:
            return "/categories"
        case .pickupLocations:
            return "/pickup-locations"
        case .me:
            return "/users/me"
        case let .user(id):
            return "/users/\(id)"
        case .updateProfile:
            return "/users/me"
        case .cart:
            return "/cart"
        case .addToCart:
            return "/cart/items"
        case let .removeFromCart(listingId):
            return "/cart/items/\(listingId)"
        case .clearCart:
            return "/cart/clear"
        case .reviewsByListing:
            return "/reviews"
        case .reviewsBySeller:
            return "/reviews"
        case .createReview:
            return "/reviews"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .register, .refreshToken, .logout, .listings, .listingDetail, .search, .categories, .pickupLocations, .reviewsByListing, .reviewsBySeller:
            return false
        case .createListing, .updateListing, .deleteListing, .confirmReceived, .uploadImages, .me, .updateProfile, .cart, .addToCart, .removeFromCart, .clearCart, .createReview:
            return true
        case .user:
            return false
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
