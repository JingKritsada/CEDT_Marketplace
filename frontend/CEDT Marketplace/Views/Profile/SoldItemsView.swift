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
