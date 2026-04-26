//
//  LoginView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) var dismiss
    var onLoginSuccess: () -> Void

    var body: some View {
        VStack(spacing: 25) {
            // 1. Header
            VStack(spacing: 15) {
                Image(systemName: "graduationcap.fill") // ไอคอนหมวกตามรูป
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Circle().fill(Color.pink))
                
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Sign in to your student account to continue.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // 3. Form
            VStack(spacing: 15) {
                CustomTextField(icon: "envelope", placeholder: "student@chula.ac.th", text: $viewModel.email)
                CustomTextField(icon: "lock", placeholder: "••••••••", text: $viewModel.password, isSecure: true)
                
                HStack {
                    Spacer()
                    Button("FORGOT PASSWORD?") { }.font(.caption2).bold().foregroundColor(.pink)
                }
            }

            // 4. Login Button
            PrimaryButton(title: "Login") {
                Task {
                    if await viewModel.login() {
                        onLoginSuccess()
                    }
                }
            }

            HStack {
                Text("Don't have an account?")
                Button("Register") { }.bold().foregroundColor(.pink)
            }
            .font(.footnote)

            Spacer()
            
            Text("AN ACADEMIC ATELIER PROJECT • CEDT CHULALONGKORN UNIVERSITY")
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
        .padding(30)
        .alert("เข้าสู่ระบบ", isPresented: $viewModel.showAlert) {
                    Button("ตกลง", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage)
                }
    }
}

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Logo Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(.systemGray6))
                    .frame(width: 200, height: 200)
                Image(systemName: "gearshape.2.fill") // หรือรูปโลโก้จริง
                    .font(.system(size: 100))
                    .foregroundColor(.pink)
            }
            
            VStack(spacing: 15) {
                Text("INNOVATION EXCHANGE").font(.caption).bold().foregroundColor(.pink)
                Text("Welcome to CEDT Marketplace").font(.title.bold()).multilineTextAlignment(.center)
                Text("Pass on your electronics and robotics gear to the next generation of engineers.").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                PrimaryButton(title: "Register") { }
                Button("Login") { }
                    .font(.headline).foregroundColor(.pink)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(15)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}
