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
    @Published var isLoading = false
    
    func fetchListings() async {
        self.isLoading = true
        do {
            // ดึงข้อมูลจริงจาก API
            let data: [Listing] = try await APIClient.shared.request(path: "/listings")
            print("Successfully fetched \(data.count) listings")
            self.listings = data
        } catch {
            print("Detailed Error: \(error)")
            // ถ้าดึงไม่ได้ค่อยให้มันไปเรียก loadMockData() เป็นแผนสำรองครับ
        }
        self.isLoading = false
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
