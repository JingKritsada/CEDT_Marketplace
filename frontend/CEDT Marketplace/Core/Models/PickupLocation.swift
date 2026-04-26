//
//  PickupLocation.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

struct PickupLocation: Codable, Identifiable {
    let id: String
    let name: String
    let building: String
    let description: String?
}
