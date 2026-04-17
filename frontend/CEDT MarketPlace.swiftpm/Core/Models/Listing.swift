//
//  Listing.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

enum ListingStatus: String, Codable, Hashable {
    case available = "AVAILABLE"
    case reserved = "RESERVED"
    case sold = "SOLD"
}

struct Listing: Codable, Identifiable, Hashable {
    let id: String
    let sellerId: String
    let title: String
    let description: String
    let price: Double
    let isFree: Bool
    let status: ListingStatus
    let condition: String?
    let courseCode: String?
    let images: [String]
    
    let contactLine: String?
    let contactIG: String?
}

extension Listing {
    static let mockListings: [Listing] = [
        Listing(
            id: "1",
            sellerId: "u1",
            title: "Arduino Uno Rev3",
            description: "Slightly used, works 100%",
            price: 0,
            isFree: true,
            status: .available,
            condition: "Good",
            courseCode: "2110101", //
            images: ["https://picsum.photos/id/1/400/400"],
            contactLine: "phachara_line",
            contactIG: nil
        ),
        Listing(
            id: "2",
            sellerId: "u2",
            title: "Infrared Sensor (x3)",
            description: "Sharp GP2Y0A21YK0F",
            price: 1500, //
            isFree: false,
            status: .available,
            condition: "Good",
            courseCode: "2110427", //
            images: ["https://picsum.photos/id/2/400/400"],
            contactLine: nil,
            contactIG: "cedt_sensors"
        ),
        Listing(
            id: "3",
            sellerId: "u3",
            title: "MB102 Breadboard",
            description: "Full size, 830 points",
            price: 45,
            isFree: false,
            status: .available,
            condition: "Good",
            courseCode: nil,
            images: ["https://picsum.photos/id/3/400/400"],
            contactLine: "breadboard_king",
            contactIG: nil
        )
    ]
}
