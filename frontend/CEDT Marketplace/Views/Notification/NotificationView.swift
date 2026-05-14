import Combine
import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel = NotificationViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        title: "No notifications", message: "We will notify you when something changes."
                    )
                } else {
                    List(viewModel.notifications) { notification in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(notification.title)
                                .font(.headline)
                            Text(notification.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(notification.createdAt.toShortString())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Notifications")
            .task { await viewModel.loadNotifications() }
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    NotificationView()
}
