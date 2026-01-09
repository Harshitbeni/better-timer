import Combine
import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif
#if os(iOS)
import BackgroundTasks
import UIKit
#endif
#if os(watchOS)
import WatchKit
#endif

public final class TimerController: ObservableObject {
    public static let shared = TimerController()

    @Published public private(set) var timers: [TimerEntry]

#if canImport(ActivityKit)
    @available(iOS 16.1, *)
    @Published public private(set) var activityID: String?

    @available(iOS 16.1, *)
    private var liveActivity: Activity<BetterTimerAttributes>?
#endif

    private let store: TimerStore
    private let engine: TimerEngine
    private var cancellables: Set<AnyCancellable> = []
#if os(iOS)
    private let backgroundScheduler = BackgroundRefreshScheduler.shared
#endif

    public init(store: TimerStore = TimerStore()) {
        self.store = store
        let savedTimers = store.loadTimers()
        self.engine = TimerEngine(timers: savedTimers)
        self.timers = savedTimers

        NotificationManager.shared.requestAuthorizationIfNeeded()

        engine.$timers
            .map { Array($0.values).sorted { $0.title < $1.title } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.timers = entries
                self?.store.saveTimers(entries)

                // Push to CloudKit in background
                Task {
                    await self?.store.pushToCloud(entries)
                }
            }
            .store(in: &cancellables)

        engine.onTick = { [weak self] entry in
            self?.handleTick(for: entry)
        }
#if os(iOS)
        backgroundScheduler.scheduleRefresh()
#endif

        // Perform initial CloudKit sync
        Task {
            await syncWithCloud()
        }
    }

    /// Syncs timers with CloudKit
    public func syncWithCloud() async {
        let syncedTimers = await store.syncWithCloud()
        await MainActor.run {
            self.timers = syncedTimers
            self.engine.setTimers(syncedTimers)
        }
    }

    public func start(timerID: UUID) {
#if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            Task {
                await requestLiveActivityIfNeeded(for: timerID)
            }
        }
#endif
        if let entry = timers.first(where: { $0.id == timerID }) {
            NotificationManager.shared.scheduleCompletionNotification(for: entry)
        }
#if os(iOS)
        backgroundScheduler.scheduleRefresh()
#endif
        engine.start(timerID: timerID)
        triggerHaptic(for: .start)
    }

    public func pause(timerID: UUID) {
        NotificationManager.shared.cancelNotification(for: timerID)
        engine.pause(timerID: timerID)
        triggerHaptic(for: .pause)
    }

    public func reset(timerID: UUID) {
#if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            endLiveActivity()
        }
#endif
        NotificationManager.shared.cancelNotification(for: timerID)
        engine.reset(timerID: timerID)
    }

    public func addTimer(title: String, totalSeconds: Int) {
        guard totalSeconds > 0 else { return }
        var updatedTimers = timers
        let newEntry = TimerEntry(title: title, totalSeconds: totalSeconds)
        updatedTimers.append(newEntry)
        setTimers(updatedTimers)
    }

    public func setTimers(_ entries: [TimerEntry]) {
        // Find deleted timer IDs
        let oldIDs = Set(timers.map { $0.id })
        let newIDs = Set(entries.map { $0.id })
        let deletedIDs = oldIDs.subtracting(newIDs)

        timers = entries
        engine.setTimers(entries)
        store.saveTimers(entries)

        // Delete from CloudKit in background
        Task {
            for deletedID in deletedIDs {
                await store.deleteFromCloud(id: deletedID)
            }
        }
    }

    private func handleTick(for entry: TimerEntry) {
#if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            if let activity = liveActivity,
               activity.attributes.timerID == entry.id {
                Task {
                    let state = BetterTimerActivityState(
                        remainingSeconds: entry.remainingSeconds,
                        title: entry.title,
                        isRunning: entry.state == .running
                    )

                    await activity.update(using: state)

                    if entry.state == .completed {
                        await activity.end(using: state, dismissalPolicy: .immediate)
                        self.liveActivity = nil
                        self.activityID = nil
                        NotificationManager.shared.presentCompletionNotification(for: entry)
                        await MainActor.run {
                            self.triggerHaptic(for: .complete)
                        }
                    }
                }
                return
            }
        }
#endif

        if entry.state == .completed {
            NotificationManager.shared.presentCompletionNotification(for: entry)
            triggerHaptic(for: .complete)
        }
    }

    private func triggerHaptic(for event: TimerHapticEvent) {
#if os(iOS)
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            switch event {
            case .start:
                generator.notificationOccurred(.success)
            case .pause:
                generator.notificationOccurred(.warning)
            case .complete:
                generator.notificationOccurred(.success)
            }
        }
#elseif os(watchOS)
        DispatchQueue.main.async {
            let hapticType: WKHapticType
            switch event {
            case .start:
                hapticType = .start
            case .pause:
                hapticType = .stop
            case .complete:
                hapticType = .success
            }

            WKInterfaceDevice.current().play(hapticType)
        }
#else
        return
#endif
    }

    private enum TimerHapticEvent {
        case start
        case pause
        case complete
    }

#if canImport(ActivityKit)
    @available(iOS 16.1, *)
    private func requestLiveActivityIfNeeded(for timerID: UUID) async {
        Config.logger.info("🔴 requestLiveActivityIfNeeded called for timer: \(timerID)")

        // Check if Live Activity already exists
        if liveActivity != nil {
            Config.logger.info("🔴 Live Activity already exists, skipping")
            return
        }

        // Check if timer entry exists
        guard let entry = timers.first(where: { $0.id == timerID }) else {
            Config.logger.error("🔴 Timer entry not found for ID: \(timerID)")
            return
        }

        Config.logger.info("🔴 Timer found: \(entry.title)")

        // Check if Live Activities are enabled
        let authInfo = ActivityAuthorizationInfo()
        Config.logger.info("🔴 Live Activities enabled: \(authInfo.areActivitiesEnabled)")

        guard authInfo.areActivitiesEnabled else {
            Config.logger.warning("🔴 Live Activities are not enabled. Enable in Settings → BetterTimer → Live Activities")
            return
        }

        let attributes = BetterTimerAttributes(
            timerID: entry.id,
            title: entry.title,
            totalSeconds: entry.totalSeconds
        )

        let contentState = BetterTimerActivityState(
            remainingSeconds: entry.remainingSeconds,
            title: entry.title,
            isRunning: true
        )

        do {
            Config.logger.info("🔴 Attempting to start Live Activity...")
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState
            )
            liveActivity = activity
            activityID = activity.id
            Config.logger.info("✅ Live Activity started for timer: \(entry.title)")
        } catch {
            Config.logger.error("❌ Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    @available(iOS 16.1, *)
    private func endLiveActivity() {
        guard let activity = liveActivity else { return }

        Task {
            let finalState = BetterTimerActivityState(
                remainingSeconds: 0,
                title: activity.attributes.title,
                isRunning: false
            )
            await activity.end(using: finalState, dismissalPolicy: .immediate)
            self.liveActivity = nil
            self.activityID = nil
        }
    }
#endif
}
