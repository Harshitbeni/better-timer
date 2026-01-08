#if os(iOS)
import BackgroundTasks
import Foundation

public final class BackgroundRefreshScheduler {
    public static let shared = BackgroundRefreshScheduler()

    private let taskIdentifier = Config.backgroundTaskIdentifier

    private init() {
        registerTask()
    }

    public func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            Config.logger.info("Background refresh scheduled")
        } catch {
            Config.logger.error("Failed to schedule background refresh: \(error.localizedDescription)")
        }
    }

    private func registerTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleRefresh(task: task as? BGAppRefreshTask)
        }
        Config.logger.info("Background task registered with identifier: \(taskIdentifier)")
    }

    private func handleRefresh(task: BGAppRefreshTask?) {
        task?.expirationHandler = { [weak task] in
            Config.logger.warning("Background refresh task expired")
            task?.setTaskCompleted(success: false)
        }

        scheduleRefresh()
        task?.setTaskCompleted(success: true)
    }
}
#endif
