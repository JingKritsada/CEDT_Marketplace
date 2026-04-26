//
//  UIComponents.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline).bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.pink)
                .cornerRadius(15)
                .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.8))
        .cornerRadius(12)
    }
}
