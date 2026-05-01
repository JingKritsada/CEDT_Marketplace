//
//  Filter.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import Foundation

struct FilterOptions {
    var selectedCategory: String? = nil
    var listingType: ListingType = .all
    var minPrice: Double = 0
    var maxPrice: Double = 5000
    
    enum ListingType: String {
        case all = "ALL", sell = "SELL", free = "FREE"
    }
}
