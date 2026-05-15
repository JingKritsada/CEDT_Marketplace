import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var paddingSize: CGFloat = 4
    var isLoading: Bool = false

    var body: some View {
        Button(action: isLoading ? {} : action) {
            ZStack {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .padding(paddingSize)
                    .opacity(isLoading ? 0 : 1)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentPrimary)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Primary", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
    }
    .padding()
}
