#if canImport(AppIntents)
import AppIntents
import Foundation

@MainActor
@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct StartTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Timer"

    @Parameter(title: "Timer Name")
    var name: String

    func perform() async throws -> some IntentResult {
        let controller = TimerController.shared
        guard let entry = controller.timers.first(where: { $0.title.caseInsensitiveCompare(name) == .orderedSame }) else {
            return .result(value: "No timer named \(name) was found.")
        }

        controller.start(timerID: entry.id)
        return .result(value: "Starting \(entry.title)")
    }
}

@MainActor
@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct PauseTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause Timer"

    @Parameter(title: "Timer Name")
    var name: String

    func perform() async throws -> some IntentResult {
        let controller = TimerController.shared
        guard let entry = controller.timers.first(where: { $0.title.caseInsensitiveCompare(name) == .orderedSame }) else {
            return .result(value: "No timer named \(name) was found.")
        }

        controller.pause(timerID: entry.id)
        return .result(value: "Paused \(entry.title)")
    }
}

@MainActor
@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct ResetTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Timer"

    @Parameter(title: "Timer Name")
    var name: String

    func perform() async throws -> some IntentResult {
        let controller = TimerController.shared
        guard let entry = controller.timers.first(where: { $0.title.caseInsensitiveCompare(name) == .orderedSame }) else {
            return .result(value: "No timer named \(name) was found.")
        }

        controller.reset(timerID: entry.id)
        return .result(value: "Reset \(entry.title)")
    }
}

@MainActor
@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct CreateTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Timer"

    @Parameter(title: "Timer Name")
    var name: String

    @Parameter(title: "Duration (minutes)")
    var duration: Double

    func perform() async throws -> some IntentResult {
        let sanitizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedName.isEmpty else {
            return .result(value: "Please provide a timer name.")
        }

        let totalSeconds = max(Int(duration * 60), 0)
        guard totalSeconds > 0 else {
            return .result(value: "Please provide a duration greater than zero.")
        }

        let controller = TimerController.shared
        controller.addTimer(title: sanitizedName, totalSeconds: totalSeconds)

        return .result(value: "Created timer \(sanitizedName) for \(duration) minute(s)")
    }
}
#endif
