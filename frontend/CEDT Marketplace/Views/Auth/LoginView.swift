import Combine
import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel

    @StateObject private var viewModel = LoginViewModel()

    @State private var isPasswordVisible = false

    var body: some View {
        VStack(spacing: 36) {
            // Header
            VStack(spacing: 20) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(18)
                    .background(Circle().fill(Color(.pink)))
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)

                VStack(spacing: 4) {
                    Text("Welcome Back")
                        .font(.system(size: 30, weight: .bold))

                    Text("Sign in to your student account to continue.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)

            // Form
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Email Address", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))

                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    Group {
                        if isPasswordVisible {
                            TextField("Password", text: $viewModel.password)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                        }
                    }

                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))

                // Error
                if let errorMessage = viewModel.errorMessage {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
            }
            Spacer()

            VStack(spacing: 18) {
                // Button
                PrimaryButton(
                    title: "Login",
                    action: {
                        Task { await viewModel.login(session: session) }
                    },
                    paddingSize: 8,
                    isLoading: viewModel.isLoading
                )
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)

                // Register
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink("Register") {
                        RegisterView()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(.pink))
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionViewModel())
}
