import Foundation
import UserNotifications

public final class NotificationManager {
    public static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let userDefaults: UserDefaults
    private let authorizationRequestedKey = "notificationAuthorizationRequested"

    private init(userDefaults: UserDefaults = UserDefaults(suiteName: AppGroup.containerIdentifier) ?? .standard) {
        self.userDefaults = userDefaults
    }

    public func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            guard settings.authorizationStatus == .notDetermined,
                  self.userDefaults.bool(forKey: authorizationRequestedKey) == false else { return }

            let options: UNAuthorizationOptions
#if os(watchOS)
            options = [.alert, .sound]
#else
            options = [.alert, .sound, .badge]
#endif

            center.requestAuthorization(options: options) { _, _ in
                self.userDefaults.set(true, forKey: self.authorizationRequestedKey)
            }
        }
    }

    public func scheduleCompletionNotification(for entry: TimerEntry) {
        let content = notificationContent(for: entry)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(entry.remainingSeconds, 1)), repeats: false)
        let request = UNNotificationRequest(identifier: entry.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    public func presentCompletionNotification(for entry: TimerEntry) {
        center.removePendingNotificationRequests(withIdentifiers: [entry.id.uuidString])
        let content = notificationContent(for: entry)
        let request = UNNotificationRequest(identifier: entry.id.uuidString, content: content, trigger: nil)
        center.add(request)
    }

    public func cancelNotification(for timerID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [timerID.uuidString])
    }

    private func notificationContent(for entry: TimerEntry) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Timer done"
        content.body = entry.title
        content.sound = .default
        return content
    }
}
