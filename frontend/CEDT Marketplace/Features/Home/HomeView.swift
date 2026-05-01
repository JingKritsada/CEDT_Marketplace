//
//  HomeView.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = ListingViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                appHeader.padding(.bottom, 15)
                searchHeader.padding(.bottom, 15)
                
                ScrollView {
                    VStack(spacing: 20) {
                        featuredBanner
                        categoryBar
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.listings) { listing in
                                let category = viewModel.categories.first(where: { $0.id == listing.categoryId })
                                let name = category?.name ?? "General"
                                
                                NavigationLink(value: listing) {
                                    ListingCard(listing: listing, categoryName: name)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        lockerCTA
                    }
                }
                .padding(.bottom, 80)
                .navigationBarHidden(true)
                
                .navigationDestination(for: Listing.self) { listing in
                    ListingDetailView(initialListing: listing, viewModel: viewModel)
                }
            }
            .task {
                await viewModel.fetchAllData()
                await userViewModel.fetchMe()
                await viewModel.fetchPickupLocations()
            }
        } // จบ NavigationStack
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

    var appHeader: some View {
        HStack(spacing: 12) {
            if let avatarUrl = userViewModel.currentUser?.avatarUrl,
                let url = URL(string: avatarUrl) {
                            
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().foregroundColor(.gray.opacity(0.1))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                             
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
            Text("CEDT Marketplace")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemPink))
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
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
                CategoryButton(
                    title: "All Items",
                    isActive: viewModel.selectedCategoryId == nil
                ) {
                    Task { await viewModel.selectCategory(nil) }
                }
                
                ForEach(viewModel.categories) { category in
                    CategoryButton(
                        title: category.name,
                        isActive: viewModel.selectedCategoryId == category.id
                    ) {
                        Task { await viewModel.selectCategory(category.id) }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).bold()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isActive ? Color.pink : Color(.systemGray6))
                .foregroundColor(isActive ? .white : .primary)
                .cornerRadius(10)
        }
    }
}
