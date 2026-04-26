//
//  APIClient.swift
//  CEDT MarketPlace
//
//  Created by Phachara Charoenkitkul on 18/4/2569 BE.
//

import Foundation

actor APIClient {
    static let shared = APIClient()
    private let baseURL = "http://localhost:3003"

    func request<T: Decodable>(path: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "user_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if httpResponse.statusCode == 401 {
                print("🚨 Access Token expired, trying to refresh...")
                
                if let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") {
                    do {
                        let refreshResponse: AuthResponse = try await self.request(
                            path: "/auth/refresh",
                            method: "POST",
                            body: ["refreshToken": refreshToken]
                        )
                        
                        UserDefaults.standard.set(refreshResponse.accessToken, forKey: "user_token")
                        
                        return try await self.request(path: path, method: method, body: body)
                        
                    } catch {
                        print("❌ Refresh Token ก็หมดอายุเหมือนกัน หรือพัง")
                        performLogout()
                        throw error
                    }
                } else {
                    performLogout()
                }
            }
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            
            if let errorLog = String(data: data, encoding: .utf8) {
                print("Server Denied: \(errorLog)")
            }
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    private func performLogout() {
            UserDefaults.standard.removeObject(forKey: "user_token")
            UserDefaults.standard.removeObject(forKey: "refresh_token")
            
            NotificationCenter.default.post(name: NSNotification.Name("UserUnauthorized"), object: nil)
        }
}
