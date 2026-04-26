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
    @Published var alertMessage = ""
    @Published var showAlert = false
    
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
    
    func publishListing(title: String, description: String, price: String, categoryId: String, pickupLocationId: String, courseCode: String) async -> Bool {
        
        guard !pickupLocationId.isEmpty else {
            self.alertMessage = "กรุณาเลือกสถานที่นัดรับ"
            self.showAlert = true
            return false
        }

        isPublishing = true
        let priceValue = Double(price) ?? 0.0

        let requestBody = CreateListingRequest(
            title: title,
            description: description,
            price: priceValue,
            categoryId: categoryId,
            pickupLocationId: pickupLocationId,
            courseCode: courseCode,
            isFree: priceValue == 0,
            images: ["https://example.com/item.jpg"]
        )
        
        do {
            let _: Listing = try await APIClient.shared.request(path: "/listings", method: "POST", body: requestBody)
            isPublishing = false
            return true
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert = true
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
