import Combine
import SwiftUI

struct ListingDetailView: View {
    let listingId: String

    @StateObject private var viewModel = ListingDetailViewModel()
    @State private var showError = false
    @State private var showCheckout = false

    var body: some View {
		ScrollView {
			
		}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
        .navigationTitle("Details")
        .navigationDestination(isPresented: $showCheckout) {
            CheckoutView()
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
			HStack(spacing: 12) {
				Button {
					Task { await viewModel.addToCart() }
				} label: {
					Image(systemName: "cart.badge.plus")
						.font(.title3.weight(.semibold))
						.foregroundColor(.accentPrimary)
						.padding(8)
				}
				.buttonStyle(.bordered)
				.tint(.accentPrimary)
				.font(.title3.weight(.semibold))

				PrimaryButton(
					title: "Purchase",
					action: {
						Task {
							await viewModel.addToCart()
							if viewModel.errorMessage == nil {
								showCheckout = true
							}
						}
					},
					paddingSize: 8,
					isLoading: viewModel.isLoading
				)
				.font(.title3.weight(.semibold))
				.frame(maxWidth: .infinity)
			}
			.padding(.horizontal, 22)
			.padding(.top, 12)
			.padding(.bottom, 16)
			.background(Color.white)
        }
        .task {
            await viewModel.loadListing(id: listingId)
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
        ListingDetailView(listingId: "cmofv0j05001peud5ftv45k30")
    }
}
