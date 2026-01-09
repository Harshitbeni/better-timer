import Foundation
import UserNotifications
import os

public final class NotificationManager {
    public static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    public func requestAuthorizationIfNeeded() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Config.notificationLogger.error("Failed to request notification authorization: \(error.localizedDescription)")
            } else if granted {
                Config.notificationLogger.info("Notification authorization granted")
            } else {
                Config.notificationLogger.warning("Notification authorization denied")
            }
        }
    }
    
    public func scheduleCompletionNotification(for timer: TimerEntry) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "\(timer.title) has finished"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(timer.remainingSeconds),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                Config.notificationLogger.error("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                Config.notificationLogger.info("Notification scheduled for timer: \(timer.title)")
            }
        }
    }
    
    public func cancelNotification(for timerID: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [timerID.uuidString])
        Config.notificationLogger.info("Cancelled notification for timer: \(timerID)")
    }
    
    public func presentCompletionNotification(for timer: TimerEntry) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "\(timer.title) has finished"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                Config.notificationLogger.error("Failed to present notification: \(error.localizedDescription)")
            }
        }
    }
}
