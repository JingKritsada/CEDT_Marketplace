import SwiftUI

struct PurchasedItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .navigationTitle("Purchased Items")
    }
}
