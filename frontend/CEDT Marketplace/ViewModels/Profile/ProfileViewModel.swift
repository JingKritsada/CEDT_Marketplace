import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService: UserService

    init(userService: UserService? = nil) {
        self.userService = userService ?? UserService()
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
    }

    func updateSocialLinks(lineId: String?, instagram: String?, facebookUrl: String?) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let payload = UpdateProfileRequest(displayName: nil, avatarUrl: nil, lineId: lineId, instagram: instagram, facebookUrl: facebookUrl)
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
