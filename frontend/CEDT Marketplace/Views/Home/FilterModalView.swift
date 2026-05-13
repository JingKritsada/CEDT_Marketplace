import Combine
import SwiftUI

struct FilterModalView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var activeQuery: ListingQuery?
    @StateObject private var viewModel = FilterViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Price") {
                    Toggle("Free only", isOn: Binding(
                        get: { viewModel.isFree == true },
                        set: { viewModel.isFree = $0 ? true : nil }
                    ))

                    TextField("Min price", text: $viewModel.minPrice)
                        .keyboardType(.numberPad)
                        .disabled(viewModel.isFree == true)

                    TextField("Max price", text: $viewModel.maxPrice)
                        .keyboardType(.numberPad)
                        .disabled(viewModel.isFree == true)
                }

                Section("Course") {
                    TextField("Course code", text: $viewModel.courseCode)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
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
        }
    }
}

#Preview {
    FilterModalView(activeQuery: .constant(nil))
}
