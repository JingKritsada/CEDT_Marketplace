import Combine
import Foundation

@MainActor
final class PostItemViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var price = ""
    @Published var isFree = false
    @Published var courseCode = ""
    @Published var selectedCategoryId: String?
    @Published var selectedPickupLocationId: String?
    @Published var condition: ListingCondition = .good
    @Published var imageUrls: [String] = []
    @Published var categories: [Category] = []
    @Published var pickupLocations: [PickupLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let listingService: ListingService
    private let categoryService: CategoryService
    private let pickupLocationService: PickupLocationService

    init(
        listingService: ListingService? = nil,
        categoryService: CategoryService? = nil,
        pickupLocationService: PickupLocationService? = nil
    ) {
        self.listingService = listingService ?? ListingService()
        self.categoryService = categoryService ?? CategoryService()
        self.pickupLocationService = pickupLocationService ?? PickupLocationService()
    }

    func loadOptions() async {
        do {
            async let categories = categoryService.fetchCategories()
            async let locations = pickupLocationService.fetchPickupLocations()
            self.categories = try await categories
            pickupLocations = try await locations
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    func submitListing() async -> Listing? {
        errorMessage = nil
        guard validateInputs() else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            let priceValue = isFree ? 0 : (Int(price) ?? 0)
            let payload = CreateListingRequest(
                title: title,
                description: description,
                price: priceValue,
                isFree: isFree,
                courseCode: courseCode.isEmpty ? nil : courseCode,
                categoryId: selectedCategoryId ?? "",
                pickupLocationId: selectedPickupLocationId ?? "",
                images: imageUrls,
                condition: condition
            )
            return try await listingService.createListing(payload)
        } catch let error as NetworkError {
            errorMessage = error.userMessage
            return nil
        } catch {
            errorMessage = NetworkError.unknown.userMessage
            return nil
        }
    }

    private func validateInputs() -> Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Title is required."
            return false
        }
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Description is required."
            return false
        }
        guard isFree || Int(price) != nil else {
            errorMessage = "Enter a valid price."
            return false
        }
        guard selectedCategoryId != nil else {
            errorMessage = "Select a category."
            return false
        }
        guard selectedPickupLocationId != nil else {
            errorMessage = "Select a pickup location."
            return false
        }
        return true
    }
}
