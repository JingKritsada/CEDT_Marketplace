import SwiftUI

struct SoldItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .navigationTitle("Sold Items")
    }
}

#Preview {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: "buyer-1",
        title: "Lab Coat",
        description: "Size M, used twice.",
        price: 150,
        isFree: false,
        status: .sold,
        condition: .likeNew,
        courseCode: nil,
        categoryId: "cat-1",
        pickupLocationId: "loc-1",
        images: [],
        createdAt: Date(),
        updatedAt: Date(),
        seller: UserSummary(id: "seller-1", displayName: "You", avatarUrl: nil),
        buyer: UserSummary(id: "buyer-1", displayName: "Jamie Student", avatarUrl: nil),
        category: Category(id: "cat-1", name: "Apparel", slug: "apparel"),
        pickupLocation: PickupLocation(id: "loc-1", name: "Science Hall", building: "F5", description: nil),
        reviews: nil
    )

    return NavigationStack {
        SoldItemsView(listings: [listing])
    }
}
