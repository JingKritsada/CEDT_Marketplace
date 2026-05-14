import Combine
import Foundation
import UIKit

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
    @Published var imagePreviews: [UIImage] = []
    @Published var categories: [Category] = []
    @Published var pickupLocations: [PickupLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let listingService: ListingService
    private let imageUploadService: ImageUploadService
    private let categoryService: CategoryService
    private let pickupLocationService: PickupLocationService
    private var imageData: [Data] = []
    private var cancellables = Set<AnyCancellable>()

    init(
        listingService: ListingService? = nil,
        imageUploadService: ImageUploadService? = nil,
        categoryService: CategoryService? = nil,
        pickupLocationService: PickupLocationService? = nil
    ) {
        self.listingService = listingService ?? ListingService()
        self.imageUploadService = imageUploadService ?? ImageUploadService()
        self.categoryService = categoryService ?? CategoryService()
        self.pickupLocationService = pickupLocationService ?? PickupLocationService()

        setupBindings()
    }

    private func setupBindings() {
        $isFree
            .sink { [weak self] isFree in
                if isFree {
                    self?.price = "0"
                }
            }
            .store(in: &cancellables)
    }

    func addImages(from dataItems: [Data]) {
        for data in dataItems {
            guard let image = UIImage(data: data) else { continue }
            imageData.append(data)
            imagePreviews.append(image)
        }
    }

    func removeImage(at index: Int) {
        guard imageData.indices.contains(index), imagePreviews.indices.contains(index) else { return }
        imageData.remove(at: index)
        imagePreviews.remove(at: index)
    }

    func loadOptions() async {
        errorMessage = nil

        do {
            let fetchedCategories = try await categoryService.fetchCategories()
            categories = fetchedCategories
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }

        do {
            let fetchedLocations = try await pickupLocationService.fetchPickupLocations()
            pickupLocations = fetchedLocations
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }

    /// Returns true and clears errorMessage if all fields are valid; otherwise sets errorMessage and returns false.
    @discardableResult
    func validate() -> Bool {
        errorMessage = nil
        return validateInputs()
    }

    func submitListing() async -> Listing? {
        errorMessage = nil
        guard validateInputs() else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            let uploadedImageUrls = try await imageUploadService.uploadListingImages(imageData)
            let priceValue = isFree ? 0 : (Int(price) ?? 0)
            let payload = CreateListingRequest(
                title: title,
                description: description,
                price: priceValue,
                isFree: isFree,
                courseCode: courseCode.isEmpty ? nil : courseCode,
                categoryId: selectedCategoryId ?? "",
                pickupLocationId: selectedPickupLocationId ?? "",
                images: uploadedImageUrls,
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

    func resetForm() {
        title = ""
        description = ""
        price = ""
        isFree = false
        courseCode = ""
        selectedCategoryId = nil
        selectedPickupLocationId = nil
        condition = .good
        imagePreviews = []
        imageData = []
        errorMessage = nil
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
            errorMessage = "Category is required."
            return false
        }
        guard selectedPickupLocationId != nil else {
            errorMessage = "Pickup location is required."
            return false
        }

        return true
    }
}
