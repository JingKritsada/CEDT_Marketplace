import Combine
import SwiftUI

struct PostItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostItemViewModel()

    var body: some View {
        Form {
            Section("Listing") {
                TextField("Title", text: $viewModel.title)
                TextField("Description", text: $viewModel.description)
            }

            Section("Pricing") {
                Toggle("Free", isOn: $viewModel.isFree)
                if !viewModel.isFree {
                    TextField("Price", text: $viewModel.price)
                        .keyboardType(.numberPad)
                }
            }

            Section("Category") {
                Picker("Category", selection: $viewModel.selectedCategoryId) {
                    Text("Select").tag(String?.none)
                    ForEach(viewModel.categories) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }
            }

            Section("Pickup") {
                Picker("Pickup Location", selection: $viewModel.selectedPickupLocationId) {
                    Text("Select").tag(String?.none)
                    ForEach(viewModel.pickupLocations) { location in
                        Text("\(location.name) - \(location.building)").tag(Optional(location.id))
                    }
                }
            }

            Section("Course") {
                TextField("Course Code", text: $viewModel.courseCode)
            }

            Section("Condition") {
                Picker("Condition", selection: $viewModel.condition) {
                    ForEach(ListingCondition.allCases, id: \.self) { condition in
                        Text(condition.displayName).tag(condition)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            Section {
                PrimaryButton(title: "Post Listing", action: {
                    Task {
                        if let _ = await viewModel.submitListing() {
                            dismiss()
                        }
                    }
                }, isLoading: viewModel.isLoading)
            }
        }
        .navigationTitle("Post Item")
        .task { await viewModel.loadOptions() }
    }
}
