//
//  FilterView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI
import Combine

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var options: FilterOptions
    let categories: [Category]
    var onApply: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    categorySection
                    listingTypeSection
                    priceRangeSection
                }
                .padding(20)
            }
            
            footerSection
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    private var headerSection: some View {
            HStack {
                Text("Filters").font(.system(size: 24, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 25)
        }

        private var categorySection: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("CATEGORY").font(.caption).bold().foregroundColor(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        categoryChip(title: "All Items", id: nil)
                        ForEach(categories) { cat in
                            categoryChip(title: cat.name, id: cat.id)
                        }
                    }
                }
            }
        }

    private var priceRangeSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("PRICE RANGE (฿)")
                .font(.caption).bold().foregroundColor(.secondary)
            
            VStack(spacing: 25) {
                RangeSlider(
                    minPrice: $options.minPrice,
                    maxPrice: $options.maxPrice,
                    range: 0...5000,
                    step: 50
                )
                .padding(.horizontal, 14)

                HStack {
                    Text("฿\(Int(options.minPrice))")
                    Spacer()
                    Text("฿\(Int(options.maxPrice))\(options.maxPrice >= 5000 ? "+" : "")")
                }
                .font(.subheadline).bold()
            }
        }
    }
        
        private var listingTypeSection: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("LISTING TYPE").font(.caption).bold().foregroundColor(.secondary)
                VStack(spacing: 12) {
                    typeCard(type: .sell, title: "Sell", subtitle: "New items for sale", icon: "tag.fill", color: .blue)
                    typeCard(type: .free, title: "Free", subtitle: "Community sharing", icon: "gift.fill", color: .green)
                }
            }
        }

        private var footerSection: some View {
            HStack(spacing: 20) {
                Button("Clear All") { options = FilterOptions() }
                    .foregroundColor(.primary).bold()
                
                Button(action: {
                    onApply()
                    dismiss()
                }) {
                    Text("Apply Filters")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.pink).cornerRadius(15)
                }
            }
            .padding(25)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
        }

        func categoryChip(title: String, id: String?) -> some View {
            let isSelected = options.selectedCategory == id
            return Text(title)
                .font(.subheadline).bold()
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? Color.pink : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .onTapGesture { options.selectedCategory = id }
        }

        func typeCard(type: FilterOptions.ListingType, title: String, subtitle: String, icon: String, color: Color) -> some View {
            let isSelected = options.listingType == type
            return HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)).frame(width: 45, height: 45)
                    Image(systemName: icon).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).bold()
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Circle()
                    .strokeBorder(isSelected ? Color.pink : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(Circle().fill(isSelected ? Color.pink : Color.clear).padding(4))
                    .frame(width: 20, height: 20)
            }
            .padding()
            .background(Color.gray.opacity(0.03))
            .cornerRadius(15)
            .onTapGesture { options.listingType = type }
        }
}
