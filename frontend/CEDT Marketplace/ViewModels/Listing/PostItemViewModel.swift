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

    @Published var sellerProfile: SellerProfile?
    @Published var isLoadingSeller = false

    /// Non-nil when editing an existing listing; the form switches into edit mode.
    @Published private(set) var editingListingId: String?

    var isEditing: Bool {
        editingListingId != nil
    }

    var isSellerActive: Bool {
        // Skip the seller gate when editing — sellers already verified at create time.
        isEditing || sellerProfile?.canAcceptPayments == true
    }

    private let listingService: ListingService
    private let imageUploadService: ImageUploadService
    private let categoryService: CategoryService
    private let pickupLocationService: PickupLocationService
    private let sellerService: SellerOnboardingService

    /// New images selected this session, parallel to the trailing portion of `imagePreviews`.
    private var imageData: [Data] = []
    /// URLs of images that already exist on the server (only populated in edit mode).
    /// These occupy the leading portion of `imagePreviews`.
    private var existingImageUrls: [String] = []
    private var cancellables = Set<AnyCancellable>()

    init(
        listingService: ListingService? = nil,
        imageUploadService: ImageUploadService? = nil,
        categoryService: CategoryService? = nil,
        pickupLocationService: PickupLocationService? = nil,
        sellerService: SellerOnboardingService? = nil
    ) {
        self.listingService = listingService ?? ListingService()
        self.imageUploadService = imageUploadService ?? ImageUploadService()
        self.categoryService = categoryService ?? CategoryService()
        self.pickupLocationService = pickupLocationService ?? PickupLocationService()
        self.sellerService = sellerService ?? SellerOnboardingService()

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
        guard imagePreviews.indices.contains(index) else { return }
        imagePreviews.remove(at: index)
        // Existing URLs occupy [0..<existingImageUrls.count]; new data occupies the rest.
        if index < existingImageUrls.count {
            existingImageUrls.remove(at: index)
        } else {
            let dataIndex = index - existingImageUrls.count
            if imageData.indices.contains(dataIndex) {
                imageData.remove(at: dataIndex)
            }
        }
    }

    /// Switch the form into edit mode, pre-filling all fields from the existing listing.
    /// Existing image URLs are kept and shown as preview placeholders; on submit they're
    /// preserved alongside any newly added images.
    func setupForEdit(listing: Listing) {
        editingListingId = listing.id
        title = listing.title
        description = listing.description
        isFree = listing.isFree
        price = listing.isFree ? "0" : String(listing.price)
        courseCode = listing.courseCode ?? ""
        selectedCategoryId = listing.categoryId ?? listing.category?.id
        selectedPickupLocationId = listing.pickupLocationId ?? listing.pickupLocation?.id
        condition = listing.condition ?? .good
        existingImageUrls = listing.images
        imageData = []
        imagePreviews = []

        // Load existing images asynchronously so the picker can show them.
        Task { [weak self, urls = listing.images] in
            for url in urls {
                guard let image = await Self.downloadImage(from: url) else { continue }
                await MainActor.run { self?.imagePreviews.append(image) }
            }
        }
    }

    private static func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    func loadSellerStatus() async {
        isLoadingSeller = true
        defer { isLoadingSeller = false }
        sellerProfile = try? await sellerService.myProfile()
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
            let allImageUrls = existingImageUrls + uploadedImageUrls
            let priceValue = isFree ? 0 : (Int(price) ?? 0)

            if let editingId = editingListingId {
                let payload = UpdateListingRequest(
                    title: title,
                    description: description,
                    price: priceValue,
                    isFree: isFree,
                    courseCode: courseCode.isEmpty ? nil : courseCode,
                    categoryId: selectedCategoryId,
                    pickupLocationId: selectedPickupLocationId,
                    images: allImageUrls,
                    status: nil,
                    buyerId: nil,
                    condition: condition
                )
                return try await listingService.updateListing(id: editingId, payload: payload)
            }

            let payload = CreateListingRequest(
                title: title,
                description: description,
                price: priceValue,
                isFree: isFree,
                courseCode: courseCode.isEmpty ? nil : courseCode,
                categoryId: selectedCategoryId ?? "",
                pickupLocationId: selectedPickupLocationId ?? "",
                images: allImageUrls,
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
        existingImageUrls = []
        editingListingId = nil
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
