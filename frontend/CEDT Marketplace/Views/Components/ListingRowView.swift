import SwiftUI

struct ListingRowView: View {
    let listing: Listing

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
                    .font(.headline)
                Text(listing.isFree ? "Free" : "THB \(listing.price)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let seller = listing.seller {
                    Text("Seller: \(seller.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                StatusBadge(status: listing.status)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: nil,
        title: "Engineering Calculator",
        description: "Lightly used calculator for exams.",
        price: 450,
        isFree: false,
        status: .available,
        condition: .good,
        courseCode: "ENGR101",
        categoryId: "cat-1",
        pickupLocationId: "loc-1",
        images: ["https://picsum.photos/200"],
        createdAt: Date(),
        updatedAt: Date(),
        seller: UserSummary(id: "seller-1", displayName: "Pat Student", avatarUrl: nil, lineId: nil, instagram: nil, facebookUrl: nil),
        buyer: nil,
        category: Category(id: "cat-1", name: "Electronics", slug: "electronics"),
        pickupLocation: PickupLocation(
            id: "loc-1", name: "Main Hall", building: "A1", description: nil
        ),
        reviews: [Review(id: "rev-1", rating: 5, comment: "Great!", reviewer: nil, createdAt: Date())]
    )

    ListingRowView(listing: listing)
        .padding()
}
