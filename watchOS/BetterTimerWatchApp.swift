import SwiftUI

@main
struct BetterTimerWatchApp: App {
    init() {
        Config.validate()
    }

    @StateObject private var timerController = TimerController(
        store: TimerStore(appGroupIdentifier: Config.appGroupIdentifier)
    )

    var body: some Scene {
        WindowGroup {
            TimersListView(timerController: timerController)
        }
    }
}
