import SwiftUI

struct ListingDetailView: View {
    // 1. รับข้อมูลเบื้องต้นมาจากหน้าก่อนหน้า
    let initialListing: Listing
    
    // 2. ตัวแปรสำหรับเก็บข้อมูลชุดเต็มหลังจากโหลดจาก /listings/:id
    @State private var detailedListing: Listing?
    
    // 3. Computed Property เพื่อเลือกใช้ข้อมูลที่ "ใหม่ที่สุด" ที่มีอยู่
    private var displayListing: Listing {
        detailedListing ?? initialListing
    }

    @EnvironmentObject var navManager: NavigationManager
    @StateObject private var userViewModel = UserViewModel()
    @ObservedObject var viewModel: ListingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 25) {
                    // --- Image Section ---
                    ZStack(alignment: .topTrailing) {
                        TabView {
                            ForEach(displayListing.images, id: \.self) { imageUrl in
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
                        // --- Title & Price ---
                        HStack(alignment: .top) {
                            Text(displayListing.title)
                                .font(.system(size: 24, weight: .bold))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Text(displayListing.isFree ? "FREE" : "฿\(Int(displayListing.price))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.pink)
                        }

                        // --- Seller Card (รูปจะขึ้นที่นี่เมื่อโหลดเสร็จ) ---
                        sellerCard

                        // --- Description ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DESCRIPTION")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(displayListing.description)
                                .font(.body)
                                .foregroundColor(.primary.opacity(0.8))
                                .lineSpacing(4)
                        }

                        // --- Pickup Location (ดึงจากก้อนข้อมูลที่ Backend ส่งมาให้โดยตรง) ---
                        if let location = displayListing.pickupLocation {
                            infoBox(
                                title: "PICKUP",
                                value: "\(location.name) (\(location.building))",
                                icon: "mappin.and.ellipse"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 80)
                .padding(.top, 130)
            }
            
            // --- Action Buttons ---
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
        .task {
            // 🚀 จังหวะนี้จะไปโหลดข้อมูลชุดเต็มเพื่อให้ได้รูป Seller และ Pickup Location ครับ
            if let fetchedListing = await viewModel.fetchListingDetail(id: initialListing.id) {
                withAnimation {
                    self.detailedListing = fetchedListing
                }
            }
            await userViewModel.fetchMe()
        }
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
    
    // --- Seller Card Component ---
    var sellerCard: some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
                // 📸 จะใช้ URL จาก detailedListing ถ้าโหลดเสร็จแล้ว
                AsyncImage(url: URL(string: displayListing.seller?.avatarUrl ?? "")) { image in
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
                    
                    if let seller = displayListing.seller {
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

    // --- Helper Views (socialButton, infoBox) เหมือนเดิม ---
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
