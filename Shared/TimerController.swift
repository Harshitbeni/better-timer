import Combine
import Foundation

public final class TimerController: ObservableObject {
    @Published public private(set) var timers: [TimerEntry]

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
    }

    public func start(timerID: UUID) {
        engine.start(timerID: timerID)
    }

    public func pause(timerID: UUID) {
        engine.pause(timerID: timerID)
    }

    public func reset(timerID: UUID) {
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
}
