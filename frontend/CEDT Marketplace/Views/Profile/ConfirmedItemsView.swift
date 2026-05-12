import SwiftUI

struct ConfirmedItemsView: View {
    let listings: [Listing]

    var body: some View {
        List(listings) { listing in
            ListingRowView(listing: listing)
        }
        .navigationTitle("Confirmed Items")
    }
}
