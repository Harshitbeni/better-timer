import Combine
import XCTest
@testable import BetterTimer

final class TimerEngineTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testCountdownCompletes() {
        let entry = TimerEntry(title: "Countdown", totalSeconds: 2)
        let engine = TimerEngine(timers: [entry])
        let timerID = entry.id

        let completion = expectation(description: "Timer completes")

        engine.onTick = { updated in
            if updated.id == timerID, updated.state == .completed {
                completion.fulfill()
            }
        }

        engine.start(timerID: timerID)

        wait(for: [completion], timeout: 3)

        let publishedEntry = engine.timers[timerID]
        XCTAssertNotNil(publishedEntry)
        XCTAssertEqual(publishedEntry?.remainingSeconds, 0)
        XCTAssertEqual(publishedEntry?.state, .completed)
    }

    func testPauseAndResume() {
        let entry = TimerEntry(title: "Pauseable", totalSeconds: 3)
        let engine = TimerEngine(timers: [entry])
        let timerID = entry.id

        let firstTick = expectation(description: "First tick received")
        let pauseHeld = expectation(description: "Timer holds while paused")
        let completion = expectation(description: "Timer completes after resume")

        engine.$timers
            .compactMap { $0[timerID] }
            .sink { updated in
                if updated.remainingSeconds == entry.totalSeconds - 1 {
                    firstTick.fulfill()
                }
                if updated.state == .completed {
                    completion.fulfill()
                }
            }
            .store(in: &cancellables)

        engine.start(timerID: timerID)
        wait(for: [firstTick], timeout: 2)

        engine.pause(timerID: timerID)
        let pausedRemaining = engine.timers[timerID]?.remainingSeconds

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertEqual(self.remainingSeconds(for: timerID, in: engine), pausedRemaining)
            pauseHeld.fulfill()
        }

        wait(for: [pauseHeld], timeout: 2)

        engine.start(timerID: timerID)
        wait(for: [completion], timeout: 5)
    }

    // Helper to safely look up the latest published value from the main thread.
    private func remainingSeconds(for id: UUID, in engine: TimerEngine) -> Int? {
        var value: Int?
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            value = engine.timers[id]?.remainingSeconds
            semaphore.signal()
        }
        semaphore.wait()
        return value
    }
}
