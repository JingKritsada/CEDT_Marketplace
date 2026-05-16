import SwiftUI

struct ToastData: Equatable {
    enum Style {
        case success, error
    }

    let message: String
    let style: Style
}

struct ToastView: View {
    let data: ToastData

    private var iconName: String {
        data.style == .success ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    private var tintColor: Color {
        data.style == .success ? .green : .red
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundColor(tintColor)
                .font(.title3)

            Text(data.message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 14, y: 4)
        .padding(.horizontal, 20)
    }
}

#Preview("Success") {
    VStack(spacing: 16) {
        ToastView(data: ToastData(message: "Item posted successfully!", style: .success))
        ToastView(data: ToastData(message: "Something went wrong. Please try again.", style: .error))
    }
    .padding()
    .background(Color(.systemGray6))
}
