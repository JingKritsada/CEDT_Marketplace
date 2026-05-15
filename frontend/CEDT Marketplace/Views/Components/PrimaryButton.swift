import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: isLoading ? {} : action) {
            ZStack {
                Text(title)
                    .opacity(isLoading ? 0 : 1)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .opacity(isLoading ? 1 : 0)
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
        .foregroundColor(.white)
        .background(isLoading ? Color.accentPrimary.opacity(0.7) : Color.accentPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Confirm", action: {})
        PrimaryButton(title: "Loading…", action: {}, isLoading: true)
    }
    .padding()
}
