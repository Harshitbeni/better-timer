#if os(iOS)
import BackgroundTasks
import Foundation

public final class BackgroundRefreshScheduler {
    public static let shared = BackgroundRefreshScheduler()

    private let taskIdentifier = "com.example.better-timer.refresh"

    private init() {
        registerTask()
    }

    public func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // In a production app this should be logged
        }
    }

    private func registerTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleRefresh(task: task as? BGAppRefreshTask)
        }
    }

    private func handleRefresh(task: BGAppRefreshTask?) {
        task?.expirationHandler = { [weak task] in
            task?.setTaskCompleted(success: false)
        }

        scheduleRefresh()
        task?.setTaskCompleted(success: true)
    }
}
#endif
