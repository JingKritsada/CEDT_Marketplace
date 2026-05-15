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

    init(userService: UserService? = nil, sellerService: SellerOnboardingService? = nil) {
        self.userService = userService ?? UserService()
        self.sellerService = sellerService ?? SellerOnboardingService()
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            profile = try await userService.getMe()
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
        } catch {
            // Not all users have a seller profile yet — silently treat as "not registered".
            sellerProfile = nil
        }
    }

    func refreshSellerStatus() async {
        do {
            sellerProfile = try await sellerService.refreshStatus()
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
        profile?.listings.filter { $0.status == .sold || $0.status == .rated } ?? []
    }

    var confirmedListings: [Listing] {
        profile?.listings.filter { $0.status == .waitingForPickup || $0.status == .sent } ?? []
    }
}
