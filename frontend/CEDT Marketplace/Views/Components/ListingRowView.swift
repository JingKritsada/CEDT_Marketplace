import SwiftUI

struct ListingRowView: View {
    let listing: Listing

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let firstImage = listing.images.first, let url = URL(string: firstImage) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
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
