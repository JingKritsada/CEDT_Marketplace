//
//  ListingViewModel.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

@MainActor
class ListingViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var categories: [Category] = []
    @Published var selectedCategoryId: String? = nil
    @Published var isLoading = false
    
    func fetchCategories() async {
            do {
                self.categories = try await APIClient.shared.request(path: "/categories")
            } catch {
                print("Categories Error: \(error)")
            }
        }
    func fetchListings() async {
            isLoading = true
            var path = "/listings"
            
            if let categoryId = selectedCategoryId {
                path += "?categoryId=\(categoryId)"
            }
            
            do {
                self.listings = try await APIClient.shared.request(path: path)
            } catch {
                print("Listings Error: \(error)")
            }
            isLoading = false
        }
    
    func selectCategory(_ categoryId: String?) async {
            selectedCategoryId = categoryId
            await fetchListings()
        }
    
    private func loadMockData() {
        self.listings = [
            Listing(
                id: "1",
                sellerId: "u1",
                title: "Arduino Uno Rev3",
                description: "สภาพดี ใช้งานได้ปกติ 100%",
                price: 0,
                isFree: true,
                status: .available,
                condition: "Good",
                courseCode: "2110101",
                images: ["https://picsum.photos/id/1/400/400"],
                contactLine: "phachara_line",
                contactIG: nil
            ),
            Listing(
                id: "2",
                sellerId: "u2",
                title: "Infrared Sensor",
                description: "Sharp GP2Y0A21YK0F ของใหม่ยังไม่แกะ",
                price: 150,
                isFree: false,
                status: .available,
                condition: "Good",
                courseCode: "2110427",
                images: ["https://picsum.photos/id/2/400/400"],
                contactLine: nil,
                contactIG: "cedt_sensors"
            )
        ]
    }
    
}
