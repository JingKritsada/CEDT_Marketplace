//
//  ListingCard.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import SwiftUI

struct ListingCard: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: listing.images.first ?? "")) { $0.resizable().aspectRatio(contentMode: .fill) }
                placeholder: { Color.gray.opacity(0.1) }
                .frame(height: 140)
                .cornerRadius(15)
                .clipped()
                
                // Badge มุมบน (เช่น FREE หรือ SENSORS)
                Text(listing.isFree ? "FREE" : "SENSORS")
                    .font(.system(size: 10, weight: .bold))
                    .padding(6)
                    .background(Color.white.opacity(0.9))
                    .foregroundColor(.pink)
                    .cornerRadius(6)
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(listing.title)
                    .font(.subheadline).bold()
                Text(listing.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(listing.isFree ? "฿0" : "฿\(Int(listing.price))")
                        .font(.headline)
                        .foregroundColor(.pink)
                    Spacer()
                    Image(systemName: "cart.badge.plus") //
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(15)
    }
}
