//
//  ImageUploadService.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

// Services/ImageUploadService.swift

// Services/ImageUploadService.swift

import Foundation
import UIKit

class ImageUploadService {
    static let shared = ImageUploadService()
    private let apiKey = "de06d0b069c3288173681876b68ec86b"

    func upload(imageData: Data) async -> String? {
        let url = URL(string: "https://api.imgbb.com/1/upload?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let originalImage = UIImage(data: imageData) else { return nil }
        
        let resizedImage = originalImage.resized(toMaxDimension: 1024)
        
        guard let finalImageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        print("📊 Original size: \(Double(imageData.count) / 1024 / 1024) MB")
        print("📊 Compressed size: \(Double(finalImageData.count) / 1024 / 1024) MB")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(finalImageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("ImgBB Error Response: \(errorJson)")
                }
                return nil
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let urlString = dataDict["url"] as? String {
                return urlString
            }
        } catch {
            print("ImgBB Upload Network Error: \(error.localizedDescription)")
        }
        return nil
    }
}

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let aspectRatio =  size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        if size.width <= maxDimension && size.height <= maxDimension {
            return self
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
