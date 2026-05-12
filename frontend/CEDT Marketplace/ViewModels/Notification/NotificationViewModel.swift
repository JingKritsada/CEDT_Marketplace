import Combine
import Foundation

@MainActor
final class NotificationViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var errorMessage: String?

    private let notificationService: NotificationService

    init(notificationService: NotificationService? = nil) {
        self.notificationService = notificationService ?? NotificationService()
    }

    func loadNotifications() async {
        do {
            notifications = try await notificationService.fetchNotifications()
        } catch let error as NetworkError {
            errorMessage = error.userMessage
        } catch {
            errorMessage = NetworkError.unknown.userMessage
        }
    }
}
