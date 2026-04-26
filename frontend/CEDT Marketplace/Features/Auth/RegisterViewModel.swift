//
//  RegisterViewModel.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import Foundation
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var studentId = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false

    func register() async -> Bool {
        guard !displayName.isEmpty, !studentId.isEmpty, !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "กรุณากรอกข้อมูลให้ครบถ้วน"
            self.showAlert = true
            return false
        }

        isLoading = true
        
        let payload = RegisterRequest(
            studentId: studentId,
            email: email,
            displayName: displayName,
            password: password
        )

        do {
            let response: AuthResponse = try await APIClient.shared.request(
                path: "/auth/register",
                method: "POST",
                body: payload
            )
            
            UserDefaults.standard.set(response.accessToken, forKey: "user_token")
            isLoading = false
            return true
        } catch {
            self.errorMessage = "สมัครสมาชิกไม่สำเร็จ: \(error.localizedDescription)"
            self.showAlert = true
            isLoading = false
            return false
        }
    }
}
