//
//  CreateListingViewModel.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 25/4/2569 BE.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI

@MainActor
class CreateListingViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var pickupLocations: [PickupLocation] = []
    @Published var isPublishing = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    // ดึงตัวเลือกจาก DB มาให้ผู้ใช้เลือกในฟอร์ม
    func fetchFormData() async {
        do {
            async let cats: [Category] = APIClient.shared.request(path: "/categories")
            async let locs: [PickupLocation] = APIClient.shared.request(path: "/pickup-locations")
            
            self.categories = try await cats
            self.pickupLocations = try await locs
        } catch {
            print("Fetch Form Data Error: \(error)")
        }
    }
    
    func publishListing(title: String, description: String, price: Double, categoryId: String, pickupLocationId: String, courseCode: String?) async -> Bool {
        isPublishing = true
        
        // สร้าง Request Object แทนการใช้ [String: Any]
        let requestBody = CreateListingRequest(
            title: title,
            description: description,
            price: price,
            categoryId: categoryId,
            pickupLocationId: pickupLocationId,
            courseCode: courseCode ?? "",
            isFree: price == 0,
            images: ["https://pub-8be35987158348928c039755b4125f46.r2.dev/items/default-item.png"]
        )
        
        do {
            // ส่ง requestBody เข้าไป ตัวแดงจะหายไปทันทีครับ
            let _: Listing = try await APIClient.shared.request(path: "/listings", method: "POST", body: requestBody)
            isPublishing = false
            return true
        } catch {
            self.alertMessage = "ลงขายไม่สำเร็จ: \(error.localizedDescription)"
            self.showingAlert = true
            isPublishing = false
            return false
        }
    }
    
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet { Task { await loadImages() } }
    }
    @Published var imagesData: [Data] = []
    
    private func loadImages() async {
        imagesData = []
            
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                imagesData.append(data)
               }
        }
    }
    func removeImage(at index: Int) {
        imagesData.remove(at: index)
        selectedItems.remove(at: index)
    }
    
}
