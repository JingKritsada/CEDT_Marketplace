import Foundation
import UserNotifications

/// Single entry point for in-app result feedback as iOS local push banners.
///
/// **House rule:** alerts are reserved for confirmation prompts only. Every action
/// result (success / failure / informational) goes through `LocalNotifier.send`.
enum LocalNotifier {
    /// Fires a banner-style notification immediately.
    static func send(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// Convenience for failure feedback.
    static func error(_ body: String, title: String = "Something went wrong") {
        send(title: title, body: body)
    }

    /// Convenience for success feedback.
    static func success(_ body: String, title: String) {
        send(title: title, body: body)
    }

    /// Requests notification permission once. Safe to call repeatedly.
    static func requestAuthorizationIfNeeded() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound
        ])
    }
}
