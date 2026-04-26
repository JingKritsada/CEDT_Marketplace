//
//  ImageUploadService.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import Foundation

class ImageUploadService {
    static let shared = ImageUploadService()
    private let apiKey = "de06d0b069c3288173681876b68ec86b" // 🔑 ใส่ Key ของคุณตรงนี้

    func upload(imageData: Data) async -> String? {
        let url = URL(string: "https://api.imgbb.com/1/upload?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // สร้าง Boundary สำหรับ Multipart Form
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let urlString = dataDict["url"] as? String {
                return urlString
            }
        } catch {
            print("ImgBB Upload Error: \(error)")
        }
        return nil
    }
}
