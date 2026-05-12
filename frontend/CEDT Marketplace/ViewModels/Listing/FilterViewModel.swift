import Combine
import Foundation

@MainActor
final class FilterViewModel: ObservableObject {
    @Published var categoryId: String?
    @Published var courseCode = ""
    @Published var isFree: Bool?
    @Published var minPrice = ""
    @Published var maxPrice = ""
    @Published var status: ListingStatus?

    func buildQuery() -> ListingQuery {
        ListingQuery(
            categoryId: categoryId,
            courseCode: courseCode.isEmpty ? nil : courseCode,
            isFree: isFree,
            minPrice: Int(minPrice),
            maxPrice: Int(maxPrice),
            status: status,
            search: nil
        )
    }
}
