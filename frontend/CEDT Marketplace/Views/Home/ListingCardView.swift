import SwiftUI

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: listing.images.first ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.2)

                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.gray)
                                .scaleEffect(1.5)
                        }
                        .aspectRatio(1, contentMode: .fill)

                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.2)

                            VStack(spacing: 6) {
                                Image(systemName: "photo")
                                    .padding(.top, 18)
                                    .font(.system(size: 28))
                                    .foregroundColor(.pink.opacity(0.6))
                                Text("No Image")
                                    .font(.caption2)
                                    .foregroundColor(.pink.opacity(0.6))
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)

                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)

                    @unknown default:
                        Color.gray.opacity(0.1)
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 15,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 15
                    )
                )

                Text((listing.category?.name ?? "No Category").uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .padding(6)
                    .background(Color.white.opacity(0.8))
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
        .background(Color.white)
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
        seller: UserSummary(id: "seller-1", displayName: "Nina Student", avatarUrl: nil),
        buyer: nil,
        category: Category(id: "cat-1", name: "Books", slug: "books"),
        pickupLocation: PickupLocation(id: "loc-1", name: "Library", building: "B2", description: nil),
        reviews: nil
    )

    return ListingCardView(listing: listing)
        .padding()
}
