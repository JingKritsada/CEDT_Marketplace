import Combine
import SwiftUI

struct FilterModalView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var activeQuery: ListingQuery?
    @StateObject private var viewModel = FilterViewModel()
    private let categoryService = CategoryService()
    @State private var categories: [Category] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.categoryId) {
                        Text("All").tag(String?.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category.id))
                        }
                    }
                }

                Section("Price") {
                    Toggle("Free only", isOn: Binding(
                        get: { viewModel.isFree == true },
                        set: { viewModel.isFree = $0 ? true : nil }
                    ))
                    TextField("Min price", text: $viewModel.minPrice)
                        .keyboardType(.numberPad)
                    TextField("Max price", text: $viewModel.maxPrice)
                        .keyboardType(.numberPad)
                }

                Section("Course") {
                    TextField("Course code", text: $viewModel.courseCode)
                }

                Section("Status") {
                    Picker("Status", selection: $viewModel.status) {
                        Text("All").tag(ListingStatus?.none)
                        ForEach(ListingStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(Optional(status))
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.categoryId = nil
                        viewModel.courseCode = ""
                        viewModel.isFree = nil
                        viewModel.minPrice = ""
                        viewModel.maxPrice = ""
                        viewModel.status = nil
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        activeQuery = viewModel.buildQuery()
                        dismiss()
                    }
                }
            }
            .task {
                do {
                    categories = try await categoryService.fetchCategories()
                } catch {
                    categories = []
                }
            }
        }
    }
}

#Preview {
    FilterModalView(activeQuery: .constant(nil))
}
