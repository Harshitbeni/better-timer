//
//  BetterTimerApp.swift
//  BetterTimer (iOS)
//
//  Main app entry point for iOS
//

import SwiftUI

@main
struct BetterTimerApp: App {
    init() {
        Config.validate()
    }

    @StateObject private var timerController = TimerController(
        store: TimerStore(
            appGroupIdentifier: Config.appGroupIdentifier,
            enableCloudSync: false  // ADD THIS LINE
        )
    )

    var body: some Scene {
        WindowGroup {
            TimersListView(timerController: timerController)
        }
    }
}
