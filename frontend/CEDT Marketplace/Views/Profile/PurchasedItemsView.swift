import SwiftUI

struct PurchasedItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Purchased Items")
    }
}

#Preview {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: "buyer-1",
        title: "Circuit Kit",
        description: "Includes breadboard and wires.",
        price: 200,
        isFree: false,
        status: .paid,
        condition: .good,
        courseCode: "EE101",
        categoryId: "cat-1",
        pickupLocationId: "loc-1",
        images: [],
        createdAt: Date(),
        updatedAt: Date(),
        seller: UserSummary(id: "seller-1", displayName: "Alex Student", avatarUrl: nil, lineId: nil, instagram: nil, facebookUrl: nil),
        buyer: UserSummary(id: "buyer-1", displayName: "You", avatarUrl: nil, lineId: nil, instagram: nil, facebookUrl: nil),
        category: Category(id: "cat-1", name: "Electronics", slug: "electronics"),
        pickupLocation: PickupLocation(
            id: "loc-1", name: "Tech Center", building: "D4", description: nil
        ),
        reviews: nil
    )

    NavigationStack {
        PurchasedItemsView(listings: [listing])
    }
}
