import SwiftUI

struct PostedItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .navigationTitle("Posted Items")
    }
}
