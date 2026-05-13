import Combine
import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

struct ListingDetailView: View {
    let listingId: String

    @StateObject private var viewModel = ListingDetailViewModel()
    @State private var showError = false
    @State private var showCheckout = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []
    @State private var showShareError = false

    var body: some View {
        ScrollView {}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .navigationTitle("Details")
            .navigationDestination(isPresented: $showCheckout) {
                CheckoutView()
            }
            .sheet(isPresented: $showShare) {
                ActivityView(activityItems: shareItems)
                    .presentationDetents([.medium])
            }
            .alert("Unable to Share", isPresented: $showShareError) {
                Button("OK") { showShareError = false }
            } message: {
                Text("No image or invalid URL.")
            }
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    shareButton
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionBar
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

    private var shareButton: some View {
        Button {
            let urlString = viewModel.listing?.images.first ?? ""
            
			guard !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let url = URL(string: urlString) else {
                showShareError = true
                return
            }

            shareItems = [url]
            showShare = true
        } label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.primary)
        }
    }

    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            addToCartButton
            purchaseButton
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color.white)
    }

    private var addToCartButton: some View {
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
    }

    private var purchaseButton: some View {
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
}

#Preview {
    NavigationStack {
        ListingDetailView(listingId: "cmofv0j05001peud5ftv45k30")
    }
}
