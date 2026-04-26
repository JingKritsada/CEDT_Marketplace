//
//  AuthContainerView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 26/4/2569 BE.
//

import SwiftUI

enum AuthStep {
    case onboarding, login, register
}

struct AuthContainerView: View {
    @State private var currentStep: AuthStep = .onboarding
    var onLoginSuccess: () -> Void
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .onboarding:
                LandingView(
                    onLoginTap: { withAnimation { currentStep = .login } },
                    onRegisterTap: { withAnimation { currentStep = .register } }
                )
                .transition(.move(edge: .leading))
                
            case .login:
                LoginView(onLoginSuccess: onLoginSuccess)
                    .overlay(alignment: .topLeading) {
                        backButton { withAnimation { currentStep = .onboarding } }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
            case .register:
                RegisterView(
                    onRegisterSuccess: onLoginSuccess,
                    onLoginTap: { withAnimation { currentStep = .login } }
                )
                .overlay(alignment: .topLeading) {
                    backButton { withAnimation { currentStep = .onboarding } }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
    
    func backButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .bold()
                .padding()
                .foregroundColor(.pink)
        }
    }
}
