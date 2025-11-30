import Combine
import Foundation

public final class TimerEngine: ObservableObject {
    @Published private(set) var timers: [UUID: TimerEntry]

    private var timersStorage: [UUID: TimerEntry]
    private var timerSources: [UUID: DispatchSourceTimer] = [:]
    private let queue = DispatchQueue(label: "com.example.better-timer.engine")

    public init(timers: [TimerEntry] = []) {
        self.timersStorage = Dictionary(uniqueKeysWithValues: timers.map { ($0.id, $0) })
        self.timers = timersStorage
    }

    public func start(timerID: UUID) {
        queue.async { [weak self] in
            guard let self, var entry = self.timersStorage[timerID] else { return }

            self.invalidateTimer(for: timerID)

            guard entry.remainingSeconds > 0 else {
                entry.state = .completed
                self.update(entry)
                return
            }

            entry.state = .running
            self.update(entry)

            let source = DispatchSource.makeTimerSource(queue: self.queue)
            source.schedule(deadline: .now() + 1, repeating: 1)
            source.setEventHandler { [weak self] in
                guard let self else { return }
                self.tick(timerID: timerID)
            }

            self.timerSources[timerID] = source
            source.resume()
        }
    }

    public func pause(timerID: UUID) {
        queue.async { [weak self] in
            guard let self, var entry = self.timersStorage[timerID] else { return }
            self.invalidateTimer(for: timerID)
            entry.state = .paused
            self.update(entry)
        }
    }

    public func reset(timerID: UUID) {
        queue.async { [weak self] in
            guard let self, var entry = self.timersStorage[timerID] else { return }
            self.invalidateTimer(for: timerID)
            entry.remainingSeconds = entry.totalSeconds
            entry.state = .idle
            self.update(entry)
        }
    }

    public func setTimers(_ entries: [TimerEntry]) {
        queue.async { [weak self] in
            guard let self else { return }
            self.timersStorage = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
            self.publishTimers()
        }
    }

    private func tick(timerID: UUID) {
        guard var entry = timersStorage[timerID] else { return }

        guard entry.remainingSeconds > 0 else {
            entry.state = .completed
            invalidateTimer(for: timerID)
            update(entry)
            return
        }

        entry.remainingSeconds -= 1
        if entry.remainingSeconds <= 0 {
            entry.remainingSeconds = 0
            entry.state = .completed
            invalidateTimer(for: timerID)
        }

        update(entry)
    }

    private func invalidateTimer(for timerID: UUID) {
        let source = timerSources.removeValue(forKey: timerID)
        source?.cancel()
    }

    private func update(_ entry: TimerEntry) {
        timersStorage[entry.id] = entry
        publishTimers()
    }

    private func publishTimers() {
        let snapshot = timersStorage
        DispatchQueue.main.async { [weak self] in
            self?.timers = snapshot
        }
    }
}
