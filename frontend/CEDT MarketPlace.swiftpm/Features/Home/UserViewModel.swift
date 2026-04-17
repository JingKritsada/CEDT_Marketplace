//
//  UserViewModel.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    
    func fetchMe() async {
        do {
            self.currentUser = try await APIClient.shared.request(path: "/users/me")
        } catch {
            print("Fetch User Error: \(error)")
        }
    }
}
