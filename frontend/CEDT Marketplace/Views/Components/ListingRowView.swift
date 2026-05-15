import SwiftUI

/// Wide horizontal card used for cart and history lists.
/// Image on the left, details on the right, status badge bottom-right.
struct ListingRowView: View {
    let listing: Listing

    private let thumbnailSize: CGFloat = 92

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                if let category = listing.category?.name {
                    Text(category.uppercased())
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.accentPrimary)
                        .lineLimit(1)
                }

                Text(listing.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let seller = listing.seller {
                    HStack(spacing: 4) {
                        Image(systemName: "person.crop.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(seller.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    Text(listing.isFree ? "Free" : "฿\(listing.price)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.accentPrimary)

                    Spacer()

                    StatusBadge(status: listing.status)
                }
            }
            .frame(maxWidth: .infinity, minHeight: thumbnailSize, alignment: .topLeading)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private var thumbnail: some View {
        let trimmed =
            listing.images.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        Group {
            if !trimmed.isEmpty,
               let url = URL(string: trimmed),
               url.scheme?.hasPrefix("http") == true
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        ZStack {
                            Color(.systemGray5)
                            ProgressView()
                                .tint(.gray)
                        }
                    case .failure:
                        placeholder(icon: "link")
                    @unknown default:
                        placeholder(icon: "photo")
                    }
                }
            } else {
                placeholder(icon: "photo")
            }
        }
        .frame(width: thumbnailSize, height: thumbnailSize)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func placeholder(icon: String) -> some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: nil,
        title: "Engineering Calculator HP 35s",
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
        seller: UserSummary(
            id: "seller-1",
            displayName: "Pat Student",
            avatarUrl: nil,
            lineId: nil,
            instagram: nil,
            facebookUrl: nil
        ),
        buyer: nil,
        category: Category(id: "cat-1", name: "Electronics", slug: "electronics"),
        pickupLocation: PickupLocation(
            id: "loc-1", name: "Main Hall", building: "A1", description: nil
        ),
        reviews: nil
    )

    ListingRowView(listing: listing)
        .padding(16)
        .background(Color(.systemGray6))
}
