//
//  profileHeader.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI

struct ProfileHeader: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.pink, lineWidth: 3))
                
                // Verified Badge
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.pink))
                    .offset(x: -5, y: -5)
            }
            
            // ใส่ชื่อจริงของคุณเป็นค่าเริ่มต้นหากไม่มีข้อมูลจาก User
            Text(user?.displayName ?? "Phachara Charoenkitkul").font(.title2).bold()
            
            HStack(spacing: 10) {
                tagLabel(text: "YEAR 3", color: Color(.systemGray6))
                tagLabel(text: "CEDT", color: Color.pink.opacity(0.1), textColor: .pink)
            }
        }
    }

    // 2. ย้ายฟังก์ชัน tagLabel เข้ามาไว้ในปีกกาของ Struct เพื่อให้อยู่ใน Scope เดียวกัน
    func tagLabel(text: String, color: Color, textColor: Color = .primary) -> some View {
        Text(text)
            .font(.caption2).bold()
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(color)
            .foregroundColor(textColor)
            .cornerRadius(5)
    }
}
