import SwiftUI

struct PostedItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Posted Items")
    }
}

#Preview {
    let listing = Listing(
        id: "listing-1",
        sellerId: "seller-1",
        buyerId: nil,
        title: "Drafting Kit",
        description: "Complete set with compass.",
        price: 300,
        isFree: false,
        status: .available,
        condition: .good,
        courseCode: nil,
        categoryId: "cat-1",
        pickupLocationId: "loc-1",
        images: [],
        createdAt: Date(),
        updatedAt: Date(),
        seller: UserSummary(id: "seller-1", displayName: "You", avatarUrl: nil),
        buyer: nil,
        category: Category(id: "cat-1", name: "Tools", slug: "tools"),
        pickupLocation: PickupLocation(
            id: "loc-1", name: "Engineering Hall", building: "E1", description: nil
        ),
        reviews: nil
    )

    return NavigationStack {
        PostedItemsView(listings: [listing])
    }
}
