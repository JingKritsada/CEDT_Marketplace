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
    let categoryId: String
    let pickupLocationId: String?
    let images: [String]
    
    let contactLine: String?
    let contactIG: String?
    
    let seller: Seller?
    let category: Category?
    let pickupLocation: PickupLocation?
}

struct CreateListingRequest: Encodable {
    let title: String
    let description: String
    let price: Double
    let categoryId: String
    let pickupLocationId: String
    let courseCode: String
    let isFree: Bool
    let images: [String]
}

struct Seller: Codable, Hashable {
    let id: String
    let displayName: String
    let avatarUrl: String?
}
