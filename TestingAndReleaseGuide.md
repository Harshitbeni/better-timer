# BetterTimer testing and release checklist

This guide walks you step by step through exercising the new unit tests, running on simulators and real devices, and shipping the macOS and iOS builds. It is written for newcomers—just follow each numbered step in order.

## 1) Run the built-in unit tests
1. Open the BetterTimer Xcode project on your Mac.
2. In the navigator, make sure the **Tests** group contains `TimerEngineTests.swift` and `TimerStoreTests.swift`.
3. Select the **BetterTimer** scheme and choose a simulator destination (e.g., **iPhone 15**). The tests run fine on any simulator because they don’t require device-only features.
4. Press **⌘U** (or choose **Product → Test**) to run the suite.
5. Confirm the following behaviors:
   - **Countdown**: `testCountdownCompletes` starts a 2-second timer and waits for it to report a completed state.
   - **Pause/Resume**: `testPauseAndResume` pauses after the first tick, verifies the remaining time is frozen, then resumes and finishes.
   - **Persistence**: `testPersistenceRoundTrip` saves sample timers into a temporary `UserDefaults` suite and reloads the exact same values.

## 2) Exercise the app on simulators
Follow these per-platform steps so you cover every supported device type.

### macOS app
1. In Xcode’s scheme picker, select the macOS target (e.g., **BetterTimer-macOS**).
2. Choose **My Mac** as the run destination.
3. Press **⌘R** to launch. Start a timer, pause it, and confirm the countdown updates in the UI.

### iPhone simulator (iOS 16.1 or newer)
1. Switch the scheme to the iOS app target.
2. Pick a simulator running iOS 16.1 or later (e.g., **iPhone 14 – iOS 16.4**).
3. Press **⌘R**, create a timer, and test pause/resume to ensure the engine matches the unit tests.

### Apple Watch simulator
1. Select the watchOS target (e.g., **BetterTimer-watchOS**).
2. Pick a paired watch simulator.
3. Press **⌘R** to deploy. Verify you can start and pause timers from the watch UI.

## 3) Live Activity and Siri on a physical iPhone
1. Connect a physical iPhone running iOS 16.1 or later.
2. In **Signing & Capabilities** for the iOS target, ensure **App Intents** and **Live Activities** are enabled and your team is selected.
3. Choose your device as the run destination and press **⌘R**.
4. Start a timer, then lock the phone—confirm the Live Activity updates the countdown.
5. Open **Shortcuts** on the device, add a new shortcut, and search for your BetterTimer intents. Run it to ensure Siri/Shortcuts can start or pause a timer.

## 4) Prepare TestFlight builds
1. Open **Product → Archive** with the iOS scheme selected.
2. When the archive finishes, click **Distribute App → App Store Connect → Upload**.
3. In App Store Connect, add internal testers, then promote to external testers after Apple’s beta review passes.
4. Share the TestFlight invite link with your testers.

## 5) Ship the macOS build
Choose the distribution path that fits your needs:

**A. Notarized DMG for direct download**
1. Archive the macOS scheme (**Product → Archive**).
2. In the Organizer, select the archive, click **Distribute App → Developer ID**.
3. Follow the prompts to sign and upload for notarization.
4. After notarization succeeds, staple the ticket (`xcrun stapler staple <YourApp>.app`) and wrap the app in a DMG for distribution.

**B. Mac App Store submission**
1. In **Signing & Capabilities**, ensure the macOS target uses your Mac App Store provisioning profile.
2. Archive the macOS scheme.
3. Choose **Distribute App → App Store Connect → Upload**.
4. In App Store Connect, fill out pricing, screenshots, and submit for review.

You now have a step-by-step path to test the timer logic, validate it on simulators and real hardware, and deliver the app through TestFlight or a notarized macOS build.
