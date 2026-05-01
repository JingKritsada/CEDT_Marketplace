//
//  itemHistoryGrid.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI
import Foundation

struct ItemHistoryGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Item History").font(.headline)
                Spacer()
                Button("VIEW ALL") {}.font(.caption).bold().foregroundColor(.pink)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                historyCard(title: "Confirmed", subtitle: "3 items ready for pickup", icon: "checkmark.circle.fill", color: .green)
                historyCard(title: "Purchased", subtitle: "View your 15 bought items", icon: "bag.fill", color: .blue)
                historyCard(title: "Posted", subtitle: "5 active listings in store", icon: "doc.text.below.ecg.fill", color: .pink)
                historyCard(title: "Sold", subtitle: "History of items you've sold", icon: "tag.fill", color: .gray)
            }
        }
        .padding(.horizontal)
    }
    func historyCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
