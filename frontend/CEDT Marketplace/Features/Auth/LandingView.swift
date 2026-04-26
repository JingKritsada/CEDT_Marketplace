//
//  LandingView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import SwiftUI

struct LandingView: View {
    var onLoginTap: () -> Void
    var onRegisterTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // ⚙️ ส่วนเฟืองและไอคอน
            ZStack {
                // Background Glow
                Circle()
                    .fill(Color.pink.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                
                // รูปเฟืองหลัก (สมมติใช้ Image จาก assets หรือ System Name)
                Image(systemName: "gearshape.2.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .foregroundColor(Color(.systemGray2))
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                
                // ไอคอนจิ๋วๆ ที่ลอยอยู่รอบๆ ตามรูป
                floatingIcon(name: "cpu", color: .pink, x: 110, y: -100)
                floatingIcon(name: "wrench.and.screwdriver.fill", color: .blue, x: -130, y: 30)
            }
            .padding(.bottom, 50)
            
            // 📝 Text Section
            VStack(spacing: 12) {
                Text("INNOVATION EXCHANGE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.pink)
                    .kerning(1.2)
                
                Text("Welcome to **CEDT**\nMarketplace")
                    .font(.system(size: 34, weight: .black))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                
                Text("Pass on your electronics and robotics gear to the next generation of engineers. Built for students, by students.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // 🔘 Buttons Section
            VStack(spacing: 16) {
                Button(action: onRegisterTap) {
                    Text("Register")
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [.pink, .init(red: 0.8, green: 0.1, blue: 0.4)], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(18)
                        .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                Button(action: onLoginTap) {
                    Text("Login")
                        .font(.headline).bold()
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(18)
                }
                
                // Footer
                HStack {
                    Circle().fill(.red).frame(width: 6, height: 6)
                    Text("Chulalongkorn University Engineering")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    func floatingIcon(name: String, color: Color, x: CGFloat, y: CGFloat) -> some View {
        Image(systemName: name)
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            .offset(x: x, y: y)
    }
}
