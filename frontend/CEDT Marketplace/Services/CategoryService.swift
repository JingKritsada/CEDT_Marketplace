import Foundation

final class CategoryService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchCategories() async throws -> [Category] {
        try await client.request(.categories)
    }
}
