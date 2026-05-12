import Combine
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = RegisterViewModel()

    var body: some View {
        Form {
            Section("Student Info") {
                TextField("Student ID", text: $viewModel.studentId)
                    .keyboardType(.numberPad)
                TextField("University Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                TextField("Display Name", text: $viewModel.displayName)
            }

            Section("Security") {
                SecureField("Password", text: $viewModel.password)
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            Section {
                PrimaryButton(title: "Register", action: {
                    Task { await viewModel.register(session: session) }
                }, isLoading: viewModel.isLoading)
            }
        }
        .navigationTitle("Register")
    }
}
