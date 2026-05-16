import SwiftUI

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                // Rectangle anchors the square — unlike Color.clear it has intrinsic
                // substance so aspectRatio(1) reliably establishes a W×W frame.
                Rectangle()
                    .foregroundColor(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        if let imageUrl = listing.images.first, !imageUrl.isEmpty,
                           URL(string: imageUrl) != nil
                        {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    Color(.systemGray5)
                                        .overlay(
                                            ProgressView().tint(.secondary).scaleEffect(1.5)
                                        )

                                case .failure:
                                    Color(.systemGray5)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "link")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(.secondary)
                                                Text("Invalid URL")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        )

                                case let .success(image):
                                    image.resizable().scaledToFill()

                                @unknown default:
                                    Color(.systemGray5)
                                }
                            }
                        } else {
                            Color(.systemGray5)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 28))
                                            .foregroundColor(.secondary)
                                        Text("No Image")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                    }
                    .clipped()

                Text((listing.category?.name ?? "No Category").uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .padding(6)
                    .background(.regularMaterial)
                    .foregroundColor(.pink)
                    .cornerRadius(8)
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(listing.title)
                    .font(.subheadline).bold()
                    .lineLimit(1)
                Text(listing.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                HStack {
                    Text(listing.isFree ? "฿0" : "฿\(Int(listing.price))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
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
        seller: UserSummary(
            id: "seller-1",
            displayName: "Nina Student",
            avatarUrl: nil,
            lineId: nil,
            instagram: nil,
            facebookUrl: nil
        ),
        buyer: nil,
        category: Category(id: "cat-1", name: "Books", slug: "books"),
        pickupLocation: PickupLocation(id: "loc-1", name: "Library", building: "B2", description: nil),
        reviews: nil
    )

    ListingCardView(listing: listing)
        .padding()
}
