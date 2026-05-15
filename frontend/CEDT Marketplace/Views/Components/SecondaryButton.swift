import SwiftUI

struct SecondaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.primary)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton("Cancel") {}
        SecondaryButton("Refresh", systemImage: "arrow.clockwise") {}
    }
    .padding()
}
