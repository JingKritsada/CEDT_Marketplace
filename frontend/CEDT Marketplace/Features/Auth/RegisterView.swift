//
//  RegisterView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    var onRegisterSuccess: () -> Void
    var onLoginTap: () -> Void
    
    @State private var isPasswordVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 1. Header Area
                VStack(spacing: 15) {
                    Image(systemName: "graduationcap.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Circle().fill(Color.pink))
                    
                    Text("Join the Community")
                        .font(.system(size: 28, weight: .black))
                    
                    Text("Create your CEDT Marketplace account to start trading with fellow students.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)

                VStack(spacing: 0) {
                    inputRow(icon: "person", label: "FULL NAME", text: $viewModel.displayName)
                    Divider().padding(.leading, 50)
                    
                    inputRow(icon: "idcard", label: "CHULA STUDENT ID", text: $viewModel.studentId)
                    Divider().padding(.leading, 50)
                    
                    inputRow(icon: "at", label: "EMAIL", text: $viewModel.email)
                    Divider().padding(.leading, 50)
                    
                    passwordRow
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                .padding(.horizontal)

                // 3. Legal Text
                Text("By creating an account, you agree to our **Terms of Service** and **Privacy Policy**.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // 4. Create Button
                Button(action: {
                    Task {
                        if await viewModel.register() { onRegisterSuccess() }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Create Account").bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding(.horizontal)

                // 5. Footer
                Button(action: onLoginTap) {
                    HStack(spacing: 4) {
                        Text("Already have an account?").foregroundColor(.secondary)
                        Text("Login").bold().foregroundColor(.pink)
                    }
                    .font(.footnote)
                }

                // 6. Bottom Decorative Images (ตาม Mockup)
                HStack(spacing: 15) {
                    roundedImage(name: "lecture_hall") // ใส่รูปใน Assets
                    roundedImage(name: "soldering_hand")
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGray6).opacity(0.3).ignoresSafeArea())
        .alert("Registration Error", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    
    func inputRow(icon: String, label: String, text: Binding<String>) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon).foregroundColor(.secondary).frame(width: 25)
            VStack(alignment: .leading, spacing: 4) {
                Text(label).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                
                TextField("", text: text)
                    .font(.subheadline)
                    .autocapitalization(.none)
            }
        }
        .padding()
    }

    var passwordRow: some View {
        HStack(spacing: 15) {
            Image(systemName: "lock").foregroundColor(.secondary).frame(width: 25)
            VStack(alignment: .leading, spacing: 4) {
                Text("PASSWORD").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                HStack {
                    if isPasswordVisible {
                        TextField("", text: $viewModel.password)
                    } else {
                        SecureField("", text: $viewModel.password)
                    }
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye").foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }
        }
        .padding()
    }

    func roundedImage(name: String) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2)) // Placeholder ถ้ายังไม่มีรูปจริง
            .frame(width: 140, height: 140)
            .cornerRadius(20)
    }
}
