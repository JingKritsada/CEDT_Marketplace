//
//  User.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    let studentId: String
    let email: String
    let displayName: String
    let avatarUrl: String?
}

