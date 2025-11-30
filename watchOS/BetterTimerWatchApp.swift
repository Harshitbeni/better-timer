import SwiftUI

@main
struct BetterTimerWatchApp: App {
    @StateObject private var timerController = TimerController(
        store: TimerStore(appGroupIdentifier: AppGroup.containerIdentifier)
    )

    var body: some Scene {
        WindowGroup {
            TimersListView(timerController: timerController)
        }
    }
}
