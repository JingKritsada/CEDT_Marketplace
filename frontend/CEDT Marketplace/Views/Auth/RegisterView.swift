import Combine
import SwiftUI

struct RegisterView: View {
	@Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel

    @StateObject private var viewModel = RegisterViewModel()

	@State private var isPasswordVisible = false
	@State private var isConfirmPasswordVisible = false

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
					Text("Join the Community")
						.font(.system(size: 30, weight: .bold))

					Text("Create your student account to get started.")
						.font(.subheadline)
						.foregroundColor(.secondary)
						.multilineTextAlignment(.center)
				}
			}
			.frame(maxWidth: .infinity)

			// Form
			VStack(alignment: .leading, spacing: 12) {
				HStack(spacing: 12) {
					Image(systemName: "person")
						.foregroundColor(.secondary)
						.frame(width: 20)

					TextField("Full Name", text: $viewModel.displayName)
						.textInputAutocapitalization(.words)
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 14)
				.background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))

				HStack(spacing: 12) {
					Image(systemName: "person.text.rectangle")
						.foregroundColor(.secondary)
						.frame(width: 20)

					TextField("Student ID", text: $viewModel.studentId)
						.textInputAutocapitalization(.never)
						.keyboardType(.numberPad)
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 14)
				.background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))

				HStack(spacing: 12) {
					Image(systemName: "envelope")
						.foregroundColor(.secondary)
						.frame(width: 20)

					TextField("University Email", text: $viewModel.email)
						.textInputAutocapitalization(.never)
						.keyboardType(.emailAddress)
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 14)
				.background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))

				Divider()
					.padding(.vertical, 8)

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

				HStack(spacing: 12) {
					Image(systemName: "lock")
						.foregroundColor(.secondary)
						.frame(width: 20)

					Group {
						if isConfirmPasswordVisible {
							TextField("Confirm Password", text: $viewModel.confirmPassword)
						} else {
							SecureField("Confirm Password", text: $viewModel.confirmPassword)
						}
					}

					Button(action: { isConfirmPasswordVisible.toggle() }) {
						Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
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
					title: "Register",
					action: {
						Task { await viewModel.register(session: session) }
					},
					paddingSize: 8,
					isLoading: viewModel.isLoading
				)
				.font(.title3.weight(.semibold))
				.frame(maxWidth: .infinity)

				// Login
				HStack(spacing: 4) {
					Text("Already have an account?")
						.foregroundColor(.secondary)
					NavigationLink("Login") {
						LoginView()
					}
					.font(.subheadline.weight(.semibold))
					.foregroundColor(Color(.pink))
				}
			}
		}
		.padding(.horizontal, 36)
    }
}

#Preview {
    RegisterView()
        .environmentObject(SessionViewModel())
}
