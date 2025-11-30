import Foundation
#if canImport(ActivityKit)
import ActivityKit

public struct BetterTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var remainingSeconds: Int
        public var title: String
        public var isRunning: Bool

        public init(remainingSeconds: Int, title: String, isRunning: Bool) {
            self.remainingSeconds = remainingSeconds
            self.title = title
            self.isRunning = isRunning
        }
    }

    public var timerID: UUID
    public var title: String
    public var totalSeconds: Int

    public init(timerID: UUID, title: String, totalSeconds: Int) {
        self.timerID = timerID
        self.title = title
        self.totalSeconds = totalSeconds
    }
}

public typealias BetterTimerActivityState = BetterTimerAttributes.ContentState
#endif
