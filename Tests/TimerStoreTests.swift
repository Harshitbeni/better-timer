import XCTest
@testable import BetterTimer

final class TimerStoreTests: XCTestCase {
    func testPersistenceRoundTrip() {
        let suiteName = "group.com.example.better-timer.tests." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create isolated user defaults")
            return
        }

        let store = TimerStore(userDefaults: defaults)
        let original = [
            TimerEntry(title: "Work", totalSeconds: 1500, remainingSeconds: 1200, state: .running),
            TimerEntry(title: "Break", totalSeconds: 300, remainingSeconds: 300, state: .idle)
        ]

        store.saveTimers(original)
        let loaded = store.loadTimers()

        XCTAssertEqual(loaded, original)
    }
}
