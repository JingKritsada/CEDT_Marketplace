import SwiftUI

struct ConfirmedItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Confirmed Items")
    }
}

#Preview {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: "buyer-1",
        title: "Safety Goggles",
        description: "Like new.",
        price: 120,
        isFree: false,
        status: .received,
        condition: .likeNew,
        courseCode: "LAB101",
        categoryId: "cat-1",
        pickupLocationId: "loc-1",
        images: [],
        createdAt: Date(),
        updatedAt: Date(),
        seller: UserSummary(id: "seller-1", displayName: "Sam Student", avatarUrl: nil),
        buyer: UserSummary(id: "buyer-1", displayName: "You", avatarUrl: nil),
        category: Category(id: "cat-1", name: "Safety", slug: "safety"),
        pickupLocation: PickupLocation(id: "loc-1", name: "Lab Lobby", building: "C3", description: nil),
        reviews: nil
    )

    return NavigationStack {
        ConfirmedItemsView(listings: [listing])
    }
}
