import SwiftUI

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let firstImage = listing.images.first, let url = URL(string: firstImage) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.2)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
            }

            Text(listing.title)
                .font(.headline)
            Text(listing.isFree ? "Free" : "THB \(listing.price)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            StatusBadge(status: listing.status)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: nil,
        title: "Engineering Textbook",
        description: "Clean pages, no highlights.",
        price: 250,
        isFree: false,
        status: .available,
        condition: .good,
        courseCode: "ENGR201",
        categoryId: "cat-1",
        pickupLocationId: "loc-1",
        images: ["https://picsum.photos/300"],
        createdAt: Date(),
        updatedAt: Date(),
        seller: UserSummary(id: "seller-1", displayName: "Nina Student", avatarUrl: nil),
        buyer: nil,
        category: Category(id: "cat-1", name: "Books", slug: "books"),
        pickupLocation: PickupLocation(id: "loc-1", name: "Library", building: "B2", description: nil),
        reviews: nil
    )

    return ListingCardView(listing: listing)
        .padding()
}
