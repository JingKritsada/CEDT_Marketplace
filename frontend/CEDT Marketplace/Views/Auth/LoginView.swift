import Combine
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        Form {
            Section("Account") {
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $viewModel.password)
            }

            Section("Social Login") {
                Button("Continue with Google") { }
                    .disabled(true)
                Button("Continue with Facebook") { }
                    .disabled(true)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            Section {
                PrimaryButton(title: "Login", action: {
                    Task { await viewModel.login(session: session) }
                }, isLoading: viewModel.isLoading)
            }
        }
        .navigationTitle("Login")
    }
}
