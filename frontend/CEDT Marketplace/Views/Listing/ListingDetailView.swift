import Combine
import SwiftUI

struct ListingDetailView: View {
    let listingId: String
    @StateObject private var viewModel = ListingDetailViewModel()
    @State private var showError = false

    var body: some View {
        ScrollView {
            if let listing = viewModel.listing {
                VStack(alignment: .leading, spacing: 16) {
                    if !listing.images.isEmpty {
                        ImageCarousel(imageUrls: listing.images)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(listing.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(listing.isFree ? "Free" : "THB \(listing.price)")
                            .font(.headline)
                        StatusBadge(status: listing.status)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(listing.description)
                            .font(.body)
                    }

                    if let seller = listing.seller {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Seller")
                                .font(.headline)
                            Text(seller.displayName)
                                .font(.subheadline)
                        }
                    }

                    if let location = listing.pickupLocation {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pickup Location")
                                .font(.headline)
                            Text("\(location.name) - \(location.building)")
                                .font(.subheadline)
                        }
                    }

                    if let reviews = listing.reviews, !reviews.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reviews")
                                .font(.headline)
                            ForEach(reviews) { review in
                                VStack(alignment: .leading, spacing: 4) {
                                    RatingStarsView(rating: Double(review.rating))
                                    if let comment = review.comment {
                                        Text(comment)
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        PrimaryButton(title: "Add to Cart", action: {
                            Task { await viewModel.addToCart() }
                        })

                        if listing.status == .waitingForPickup || listing.status == .sent {
                            PrimaryButton(title: "Confirm Received", action: {
                                Task { await viewModel.confirmReceived() }
                            })
                        }
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                EmptyStateView(title: "Listing not found", message: "Please try again later.")
            }
        }
        .navigationTitle("Details")
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
        ListingDetailView(listingId: "listing-1")
    }
}
