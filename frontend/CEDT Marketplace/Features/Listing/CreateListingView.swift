//
//  CreateListingView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 25/4/2569 BE.
//

import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Form States
    @State private var title = ""
    @State private var price = ""
    @State private var description = ""
    @State private var courseCode = ""
    @State private var selectedCategoryId = ""
    @State private var isSpotlight = false
    @State private var selectedLocationId = ""
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Header
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 2. Item Gallery
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("ITEM GALLERY").sectionTitle()
                            Spacer()
                            Text("\(viewModel.imagesData.count) / 5 Photos")
                                .font(.caption).foregroundColor(.secondary)
                        }
                                            
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                                    
                                PhotosPicker(
                                    selection: $viewModel.selectedItems,
                                    maxSelectionCount: 5, // บรรทัดนี้สำคัญครับ!
                                    matching: .images
                                ) {
                                    addPhotoButton
                                }
                                                    
                                ForEach(0..<viewModel.imagesData.count, id: \.self) { index in
                                    if let uiImage = UIImage(data: viewModel.imagesData[index]) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(15)
                                                .clipped()
                                                                
                                            Button(action: { viewModel.removeImage(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.5).clipShape(Circle()))
                                            }
                                                .padding(5)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 3. Item Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ITEM NAME").sectionTitle()
                        customTextField(placeholder: "e.g. Raspberry Pi 4 Model B", text: $title)
                    }
                    
                    // 4. Category Selector (Horizontal)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CATEGORY").sectionTitle()
                        categorySelector
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PICKUP LOCATION").sectionTitle()
                        
                        Menu {
                            Picker("Select Location", selection: $selectedLocationId) {
                                Text("Select a spot...").tag("")
                                ForEach(viewModel.pickupLocations) { loc in
                                    Text("\(loc.building) - \(loc.name)").tag(loc.id)
                                }
                            }
                        } label: {
                            HStack {
                                let selectedLoc = viewModel.pickupLocations.first(where: { $0.id == selectedLocationId })
                                Text(selectedLoc != nil ? "\(selectedLoc!.building) (\(selectedLoc!.name))" : "Where to meet?")
                                    .foregroundColor(selectedLocationId.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.down").font(.caption).foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("COURSE CODE (OPTIONAL)").sectionTitle()
                        customTextField(placeholder: "e.g. 2110316", text: $courseCode).keyboardType(.numberPad)
                    }
                    
                    // 5. Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPTION").sectionTitle()
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Mention condition, usage history, and what's included in the box...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 12)
                                    .padding(.leading, 12)
                            }
                            TextEditor(text: $description)
                                .frame(height: 80)
                                .scrollContentBackground(.hidden)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                        }
                    }
                    
                    // 6. Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRICE").sectionTitle()
                        HStack {
                            Text("฿").foregroundColor(.secondary)
                            TextField("0.00", text: $price)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    
                    // 7. Spotlight Toggle Box
//                    HStack(spacing: 15) {
//                        Image(systemName: "sparkles")
//                            .font(.title2)
//                            .foregroundColor(.blue)
//                            .padding(10)
//                            .background(Color.blue.opacity(0.1))
//                            .cornerRadius(10)
//                        
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("Spotlight Listing").font(.subheadline).bold()
//                            Text("Push your item to the top of the feed.").font(.caption2).foregroundColor(.secondary)
//                        }
//                        
//                        Spacer()
//                        
//                        Toggle("", isOn: $isSpotlight)
//                            .labelsHidden()
//                            .tint(.pink)
//                    }
//                    .padding()
//                    .background(Color.blue.opacity(0.05))
//                    .cornerRadius(15)
                    
                    // 8. Post Button & Legal Text
                    VStack(spacing: 15) {
                        Button(action: {
                            Task {
                                let success = await viewModel.publishListing(
                                    title: title,
                                    description: description,
                                    price: price,
                                    categoryId: selectedCategoryId,
                                    pickupLocationId: selectedLocationId,
                                    courseCode: courseCode
                                )
                                if success {
                                    withAnimation(.spring()) {
                                        selectedTab = .home
                                    }
                                    dismiss()
                                }
                            }
                        }) {
                            if viewModel.isPublishing {
                                ProgressView().tint(.white) // แสดง Loading ตอนกำลังส่ง
                            } else {
                                Text("Post Item").font(.headline).bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .disabled(viewModel.isPublishing) // กันกดซ้ำ
                    }
                    HStack {
                        Spacer()
                        Text("By posting, you agree to the CEDT Community Marketplace Terms of Service and Honor Code.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: 250)
                        Spacer()
                    }
                    .alert("แจ้งเตือน", isPresented: $viewModel.showAlert) {
                        Button("ตกลง", role: .cancel) { }
                    } message: {
                        Text(viewModel.alertMessage)
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .padding(.bottom, 100)
        .task { await viewModel.fetchFormData() } // ดึงข้อมูล Category จริงจาก DB
    }
    
    // --- Helper Components ---
    
    var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.spring()) {
                    selectedTab = .home
                }
            }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.pink)
            }
            Spacer()
            Text("Post New Item").font(.headline).bold()
            Spacer()
            Image(systemName: "xmark").opacity(0)
            }
            .padding()
        }
    
    var addPhotoButton: some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.title2)
            Text("Add Photo").font(.caption2).bold()
        }
        .foregroundColor(.pink)
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(.pink.opacity(0.3))
        )
    }
    
    var roundedPlaceholder: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemGray6))
            .frame(width: 120, height: 120)
            .overlay(Image(systemName: "photo").foregroundColor(.gray.opacity(0.3)))
    }
    
    var categorySelector: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.categories) { cat in
                Button(action: { selectedCategoryId = cat.id }) {
                    Text(cat.name)
                        .font(.caption).bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedCategoryId == cat.id ? Color.white : Color.clear)
                        .foregroundColor(selectedCategoryId == cat.id ? .pink : .primary)
                        .cornerRadius(10)
                        .padding(2)
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6).opacity(0.8))
        .cornerRadius(12)
    }
    
    func customTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
    }
}

// --- View Modifiers ---
extension Text {
    func sectionTitle() -> some View {
        self.font(.system(size: 12, weight: .bold))
            .foregroundColor(.secondary)
    }
}
