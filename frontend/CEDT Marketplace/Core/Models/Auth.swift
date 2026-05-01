//
//  Auth.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    
    let user: UserProfile?
}

struct UserProfile: Decodable {
    let id: String
    let email: String
    let displayName: String
}

struct RegisterRequest: Encodable {
    let studentId: String
    let email: String
    let displayName: String
    let password: String
}
