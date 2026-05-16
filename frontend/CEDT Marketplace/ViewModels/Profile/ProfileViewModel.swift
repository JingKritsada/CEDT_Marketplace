import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var sellerProfile: SellerProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Seller-onboarding flow state.
    @Published var onboardingURL: URL?
    @Published var isStartingOnboarding = false

    private let userService: UserService
    private let sellerService: SellerOnboardingService
    private let listingService: ListingService

    init(
        userService: UserService? = nil,
        sellerService: SellerOnboardingService? = nil,
        listingService: ListingService? = nil
    ) {
        self.userService = userService ?? UserService()
        self.sellerService = sellerService ?? SellerOnboardingService()
        self.listingService = listingService ?? ListingService()
    }

    /// Delete one of the current user's listings. The listing service rejects deletes
    /// for listings the caller doesn't own, so we don't pre-check ownership here.
    func deleteListing(id: String) async -> Bool {
        do {
            try await listingService.deleteListing(id: id)
            await loadProfile()
            return true
        } catch let error as NetworkError {
            errorMessage = error.userMessage
            return false
        } catch {
            errorMessage = NetworkError.unknown.userMessage
            return false
        }
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            profile = try await userService.getMe()
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }

        await loadSellerProfile()
    }

    func loadSellerProfile() async {
        do {
            sellerProfile = try await sellerService.myProfile()
        } catch is CancellationError {
            return
        } catch {
            // Not all users have a seller profile yet — silently treat as "not registered".
            sellerProfile = nil
        }
    }

    func refreshSellerStatus() async {
        do {
            sellerProfile = try await sellerService.refreshStatus()
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func startSellerOnboarding() async {
        isStartingOnboarding = true
        defer { isStartingOnboarding = false }
        do {
            let response = try await sellerService.startOnboarding()
            if let url = URL(string: response.url) {
                onboardingURL = url
            } else {
                errorMessage = "Onboarding link is invalid."
            }
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func updateDisplayInfo(displayName: String, avatarData: Data?) async {
        isLoading = true
        defer { isLoading = false }
        var uploadedAvatarUrl: String? = nil
        if let data = avatarData {
            uploadedAvatarUrl = try? await ImageUploadService().uploadListingImages([data]).first
        }
        do {
            let payload = UpdateProfileRequest(
                displayName: displayName,
                avatarUrl: uploadedAvatarUrl,
                lineId: nil, instagram: nil, facebookUrl: nil
            )
            profile = try await userService.updateProfile(payload)
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func updateSocialLinks(lineId: String?, instagram: String?, facebookUrl: String?) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let payload = UpdateProfileRequest(
                displayName: nil, avatarUrl: nil, lineId: lineId, instagram: instagram,
                facebookUrl: facebookUrl
            )
            profile = try await userService.updateProfile(payload)
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    var postedListings: [Listing] {
        profile?.listings.filter { $0.sellerId == profile?.id } ?? []
    }

    var purchasedListings: [Listing] {
        profile?.listings.filter { $0.buyerId == profile?.id } ?? []
    }

    var soldListings: [Listing] {
        profile?.listings.filter { $0.sellerId == profile?.id && ( $0.status == .received || $0.status == .sent || $0.status == .rated ) } ?? []
    }

    var confirmedListings: [Listing] {
        profile?.listings.filter { $0.sellerId == profile?.id && ( $0.status == .waitingForPickup || $0.status == .paid ) } ?? []
    }
}
