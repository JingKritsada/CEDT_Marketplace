import Combine
import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let cart = viewModel.cart, !cart.items.isEmpty {
                    List {
                        ForEach(cart.items) { item in
                            ListingRowView(listing: item.listing)
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { cart.items[$0].listingId }
                            Task {
                                for id in ids {
                                    await viewModel.removeItem(listingId: id)
                                }
                            }
                        }

                        NavigationLink("Checkout") {
                            CheckoutView()
                        }
                    }
                } else {
                    EmptyStateView(title: "Cart is empty", message: "Browse listings and add items to cart.")
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                if viewModel.cart != nil {
                    Button("Clear") {
                        Task { await viewModel.clearCart() }
                    }
                }
            }
            .task { await viewModel.loadCart() }
        }
    }
}

#Preview {
    CartView()
}
