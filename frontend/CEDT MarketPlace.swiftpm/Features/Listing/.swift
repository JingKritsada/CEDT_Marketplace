//
//  CreateListingView.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import SwiftUI

struct CreateListingView: View {
    // --- State Variables สำหรับเก็บข้อมูลในฟอร์ม ---
    @State private var title = ""
    @State private var courseCode = ""
    @State private var price = ""
    @State private var description = ""
    @State private var lineId = ""
    @State private var instagram = ""
    @State private var selectedCategory: String? = nil
    
    // Mock Data สำหรับหมวดหมู่ (เดี๋ยวค่อยเชื่อม API ใน Commit ถัดๆ ไป)
    let categories = ["Sensors", "Micro-controllers", "Boards", "Others"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header Area (Profile)
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Your Profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("👤 Thatchaphon P.") //
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    // --- 1. Basic Info Section ---
                    VStack(alignment: .leading, spacing: 15) {
                        formField(title: "Listing Title", placeholder: "What are you selling?", text: $title)
                        
                        formField(title: "Course Code (Optional)", placeholder: "e.g., 2110101", text: $courseCode) //
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Price").font(.headline)
                            HStack {
                                Text("฿").font(.title2).bold().foregroundColor(.pink)
                                TextField("0", text: $price)
                                    .keyboardType(.decimalPad)
                            }
                            .inputStyle()
                        }
                    }
                    
                    // --- 2. Category Picker & Description ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Item Category").font(.headline)
                        Menu {
                            ForEach(categories, id: \.self) { cat in
                                Button(cat) { selectedCategory = cat }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory ?? "SELECT CATEGORY")
                                    .foregroundColor(selectedCategory == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.secondary)
                            }
                            .inputStyle()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item Description").font(.headline)
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                    }
                    
                    // --- 3. Photos Section ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photos").font(.headline)
                        Text("Add up to 5 photos.").font(.caption).foregroundColor(.secondary)
                        
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                Text("Add Photos")
                                    .font(.caption2)
                            }
                            .foregroundColor(.pink)
                            .frame(width: 90, height: 90)
                            .background(Color.pink.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    
                    // --- 4. Pickup Location (Placeholder) ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pickup Location").font(.headline)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.title2)
                                .foregroundColor(.pink)
                                .frame(width: 50, height: 50)
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading) {
                                Text("Larn Gear, Faculty of Engineering") //
                                    .font(.subheadline).bold()
                                Text("Verfied Pickup Point")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.secondary)
                        }
                        .inputStyle()
                    }
                    
                    // --- 5. Contact Info Section (Hidden Logic coming later) ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Contact Info").font(.headline)
                            Text("(Hidden until request accepted)").font(.caption2).foregroundColor(.secondary)
                        }
                        TextField("LINE ID", text: $lineId).inputStyle() //
                        TextField("Instagram Username", text: $instagram).inputStyle() //
                    }
                    .padding(.bottom, 20)
                    
                    // --- Publish Button ---
                    Button(action: {
                        // Action สำหรับส่งข้อมูลไป API (เดี๋ยวทำใน Phase Integration)
                    }) {
                        Text("Publish Listing") //
                            .font(.headline).bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(15)
                    }
                    .padding(.bottom, 40)
                    
                }
                .padding(.horizontal)
            }
            .navigationTitle("Create a New Listing") //
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // --- Helper Views เพื่อให้โค้ดสะอาด ---
    @ViewBuilder
    func formField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            TextField(placeholder, text: text)
                .inputStyle()
        }
    }
}

// --- View Modifier สำหรับตกแต่งช่อง Input ---
struct InputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
    }
}

extension View {
    func inputStyle() -> some View {
        modifier(InputStyle())
    }
}
