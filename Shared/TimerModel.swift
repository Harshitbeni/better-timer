import Foundation

public enum TimerState: String, Codable {
    case idle
    case running
    case paused
    case completed
}

public struct TimerEntry: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var totalSeconds: Int
    public var remainingSeconds: Int
    public var state: TimerState

    public init(
        id: UUID = UUID(),
        title: String,
        totalSeconds: Int,
        remainingSeconds: Int? = nil,
        state: TimerState = .idle
    ) {
        self.id = id
        self.title = title
        self.totalSeconds = totalSeconds
        self.remainingSeconds = remainingSeconds ?? totalSeconds
        self.state = state
    }
}
