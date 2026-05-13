import Combine
import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    private let pickupService = PickupLocationService()
    @State private var pickupLocations: [PickupLocation] = []
    @State private var showError = false

    var body: some View {
        Form {
            Section("Pickup Location") {
                Picker("Pickup", selection: $viewModel.selectedPickupLocationId) {
                    Text("Select").tag(String?.none)
                    ForEach(pickupLocations) { location in
                        Text("\(location.name) - \(location.building)").tag(Optional(location.id))
                    }
                }
            }

            Section {
                PrimaryButton(title: "Confirm Order", action: {
                    viewModel.confirmOrder()
                })
            }
        }
        .navigationTitle("Checkout")
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
        .task {
            do {
                pickupLocations = try await pickupService.fetchPickupLocations()
            } catch {
                pickupLocations = []
            }
        }
        .alert("Order Confirmed", isPresented: $viewModel.isConfirmed) {
            Button("OK") {}
        } message: {
            Text("Your pickup details have been saved.")
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showError = newValue != nil
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
    }
}
