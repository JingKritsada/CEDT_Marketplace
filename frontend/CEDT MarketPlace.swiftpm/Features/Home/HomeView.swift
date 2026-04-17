//
//  HomeView.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ListingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ส่วนบนคงที่
                searchHeader.padding(.bottom, 15)
                
                ScrollView {
                    VStack(spacing: 20) {
                        featuredBanner
                        categoryBar
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.listings) { listing in
                                NavigationLink(value: listing) {
                                    ListingCard(listing: listing)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        lockerCTA
                    }
                }
                .navigationBarHidden(true)
                .task {
                    await viewModel.fetchListings()
               }
            }
        }
    }
    var lockerCTA: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Clean out your locker!")
                    .font(.headline).bold()
                Text("Turn your old lab components into cash.")
                    .font(.caption)
                Button(action: {}) {
                    Label("List an Item", systemImage: "plus")
                        .font(.subheadline).bold()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 5)
            }
            Spacer()
            Image(systemName: "archivebox")
                .font(.system(size: 50))
                .foregroundColor(.pink.opacity(0.2))
        }
        .padding(20)
        .background(Color.pink.opacity(0.05))
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    var searchHeader: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search components...", text: .constant("")) //
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button(action: {}) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }


    var featuredBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FEATURED LISTING")
                .font(.caption).bold()
                .opacity(0.8)
            
            Text("Oscilloscope\nKit Pro")
                .font(.title).bold()
            
            Text("Perfect for your Signal Processing project. Verified by Lab Staff.")
                .font(.subheadline)
            
            Button("View Deal") { }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(10)
        }
        .foregroundColor(.white)
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .padding(.horizontal)
    }

    var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(title: "All Items", isActive: true)
                CategoryButton(title: "Micro-controllers", isActive: false) //
                CategoryButton(title: "Sensors", isActive: false)
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isActive: Bool
    var body: some View {
        Text(title)
            .font(.subheadline).bold()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isActive ? Color.pink : Color(.systemGray6))
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(10)
    }
}
