import SwiftUI

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
