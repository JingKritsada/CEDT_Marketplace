//
//  ListingDetailView.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @EnvironmentObject var navManager: NavigationManager
    @StateObject private var userViewModel = UserViewModel()
    @ObservedObject var viewModel: ListingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 25) {
                    ZStack(alignment: .topTrailing) {
                        TabView {
                            ForEach(listing.images, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 370, height: 300)
                                        .clipped()
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.1))
                                        .frame(width: 370, height: 300)
                                }
                            }
                        }
                        .frame(width: 370, height: 300)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .cornerRadius(20)
                        
                        Text("AUTHENTIC")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(.pink)
                            .clipShape(Capsule())
                            .padding(20)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top) {
                            Text(listing.title)
                                .font(.system(size: 24, weight: .bold))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Text(listing.isFree ? "FREE" : "฿\(Int(listing.price))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.pink)
                        }

                        sellerCard

                        VStack(alignment: .leading, spacing: 10) {
                            Text("DESCRIPTION")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(listing.description)
                                .font(.body)
                                .foregroundColor(.primary.opacity(0.8))
                                .lineSpacing(4)
                        }

                        if let locId = listing.pickupLocationId {
                            let locationName = viewModel.pickupLocations.first(where: { $0.id == locId })?.name ?? "Faculty of Engineering"
                            let BuildingName = viewModel.pickupLocations.first(where: { $0.id == locId })?.building ?? "Faculty of Engineering"
                            infoBox(title: "PICKUP", value: locationName + "(" + BuildingName + ")", icon: "mappin.and.ellipse")
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 80)
                .padding(.top, 130)
                
            }
            HStack(spacing: 15) {
                Button(action: {}) {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                }
                
                Button(action: {}) {
                    Text("Purchase Instantly")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.pink)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            .task {
                await userViewModel.fetchMe()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
        .onAppear {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        navManager.isTabBarHidden = true
                    }
                }
                .onDisappear {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        navManager.isTabBarHidden = false
                    }
                }
    }
    
    var sellerCard: some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: listing.seller?.avatarUrl ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("LISTED BY").font(.caption2).foregroundColor(.secondary)
                    
                    if let seller = listing.seller {
                        Text("\(seller.displayName)").font(.subheadline).bold()
                        
                    } else {
                        Text("Unknown Seller").font(.subheadline).foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            
            HStack(spacing: 10) {
                socialButton(title: "LINE", icon: "message.fill", color: .green)
                socialButton(title: "FACEBOOK", icon: "f.circle.fill", color: .blue)
                socialButton(title: "INSTAGRAM", icon: "camera.fill", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(20)
    }
    
    // --- Helper Views ---
    
    func socialButton(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption)
            Text(title).font(.system(size: 10, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .foregroundColor(color)
        .cornerRadius(10)
    }
    
    func infoBox(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .font(.title3)
            VStack(alignment: .leading) {
                Text(title).font(.caption2).foregroundColor(.secondary).bold()
                Text(value).font(.subheadline).bold()
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(15)
    }
}
