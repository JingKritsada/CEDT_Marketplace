//
//  Category.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let slug: String
}
