import SwiftUI

struct SocialSignInButton: View {
    let provider: SocialProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                icon
                Text("Continue with \(provider.displayName)")
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(foreground)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray4), lineWidth: provider == .google ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var icon: some View {
        switch provider {
        case .google:
            // Replace with an Asset Catalog image named "google_logo" for the official mark.
            Image(systemName: "g.circle.fill")
                .font(.title3)
        case .apple:
            Image(systemName: "applelogo")
                .font(.title3)
        case .facebook:
            Image(systemName: "f.cursive.circle.fill")
                .font(.title3)
        }
    }

    private var foreground: Color {
        switch provider {
        case .google: .primary
        case .apple: .white
        case .facebook: .white
        }
    }

    private var background: Color {
        switch provider {
        case .google: Color(.systemBackground)
        case .apple: .black
        case .facebook: Color(red: 24 / 255, green: 119 / 255, blue: 242 / 255)
        }
    }
}
