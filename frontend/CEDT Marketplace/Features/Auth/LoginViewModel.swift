//
//  LoginViewModel.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import Foundation
import Combine
import SwiftUI


@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    
    @Published var errorMessage = ""
    @Published var showAlert = false


    func login() async -> Bool {
        self.showAlert = false
        self.errorMessage = ""
        
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "กรุณากรอกข้อมูลให้ครบถ้วน"
            self.showAlert = true
            return false
        }
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        isLoading = true
        
        do {
            let response: AuthResponse = try await APIClient.shared.request(
                path: "/auth/login",
                method: "POST",
                body: ["email": cleanedEmail, "password": password]
            )

            UserDefaults.standard.set(response.accessToken, forKey: "user_token")
            UserDefaults.standard.set(response.refreshToken, forKey: "refresh_token")
            
            self.showAlert = false
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            print("Login Error Detail: \(error)")
                    
            if let decodingError = error as? DecodingError {
                self.errorMessage = "แกะข้อมูลจากเซิร์ฟเวอร์ไม่สำเร็จ (Decoding Error)"
            } else {
                self.errorMessage = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
            }
                    
            self.showAlert = true
            return false
        }
    }
}
