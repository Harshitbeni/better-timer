import Combine
import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

public final class TimerController: ObservableObject {
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

    public init(store: TimerStore = TimerStore()) {
        self.store = store
        let savedTimers = store.loadTimers()
        self.engine = TimerEngine(timers: savedTimers)
        self.timers = savedTimers

        engine.$timers
            .map { Array($0.values).sorted { $0.title < $1.title } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.timers = entries
                self?.store.saveTimers(entries)
            }
            .store(in: &cancellables)

#if canImport(ActivityKit)
        engine.onTick = { [weak self] entry in
            self?.handleTick(for: entry)
        }
#endif
    }

    public func start(timerID: UUID) {
#if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            Task {
                await requestLiveActivityIfNeeded(for: timerID)
            }
        }
#endif
        engine.start(timerID: timerID)
    }

    public func pause(timerID: UUID) {
        engine.pause(timerID: timerID)
    }

    public func reset(timerID: UUID) {
#if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            endLiveActivity()
        }
#endif
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
        timers = entries
        engine.setTimers(entries)
        store.saveTimers(entries)
    }

#if canImport(ActivityKit)
    @available(iOS 16.1, *)
    private func requestLiveActivityIfNeeded(for timerID: UUID) async {
        guard liveActivity == nil,
              let entry = timers.first(where: { $0.id == timerID }),
              ActivityAuthorizationInfo().areActivitiesEnabled else { return }

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
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState
            )
            liveActivity = activity
            activityID = activity.id
        } catch {
            // In a production app this should be logged
        }
    }

    @available(iOS 16.1, *)
    private func handleTick(for entry: TimerEntry) {
        guard let activity = liveActivity,
              activity.attributes.timerID == entry.id else { return }

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
            }
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
