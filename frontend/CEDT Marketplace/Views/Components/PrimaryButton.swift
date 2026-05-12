import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var paddingSize: CGFloat = 4
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity)
                    .padding(paddingSize + 4)
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .padding(paddingSize)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentPrimary)
    }
}

#Preview {
    PrimaryButton(title: "Primary", action: {})
        .padding()
}
