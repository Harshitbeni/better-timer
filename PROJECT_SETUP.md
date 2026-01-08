# BetterTimer - Xcode Project Setup Guide

This guide walks you through creating an Xcode project for BetterTimer from the source files.

## Overview

BetterTimer is a multi-platform app that runs on:
- **iOS 16.1+** - iPhone and iPad
- **macOS 13.0+** - Mac computers
- **watchOS 9.0+** - Apple Watch

The source code is organized into platform-specific folders that you'll need to add to separate targets in Xcode.

## Prerequisites

- macOS 13.0 or later
- Xcode 14.0 or later
- Apple Developer account (free or paid)
- Basic familiarity with Xcode

## Step 1: Create the Base Project

1. Open **Xcode**

2. Select **File → New → Project** (or press ⇧⌘N)

3. In the template chooser:
   - Select the **iOS** tab at the top
   - Choose **App** template
   - Click **Next**

4. Configure the project:
   - **Product Name:** `BetterTimer`
   - **Team:** Select your Apple Developer team
   - **Organization Identifier:** `com.yourteam` (replace with your team/personal identifier)
   - **Bundle Identifier:** Will auto-fill to `com.yourteam.BetterTimer`
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - **Storage:** **None**
   - **Include Tests:** ✅ Check this box
   - Click **Next**

5. Choose where to save the project (can be outside the source folder)

6. Click **Create**

## Step 2: Configure the iOS Target

### Update Config.swift

Before adding files, update identifiers in `Shared/Config.swift`:

```swift
// Replace these with your team's identifiers
static let appGroupIdentifier = "group.com.yourteam.better-timer"
static let backgroundTaskIdentifier = "com.yourteam.better-timer.refresh"
static let timerQueueIdentifier = "com.yourteam.better-timer.engine"
static let cloudKitContainerIdentifier = "iCloud.com.yourteam.better-timer"
```

### Add Shared Files

1. In Xcode's Project Navigator, right-click on the project and select **Add Files to "BetterTimer"**

2. Navigate to the `Shared/` folder in the source directory

3. Select **all files** in the Shared folder:
   - Config.swift
   - TimerModel.swift
   - TimerEngine.swift
   - TimerStore.swift
   - TimerController.swift
   - CloudKitSyncManager.swift
   - NotificationManager.swift
   - BackgroundRefreshScheduler.swift
   - BetterTimerActivity.swift
   - BetterTimerLiveActivity.swift
   - BetterTimerIntents.swift

4. **Important:** Check these options:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ Select **all targets** where these files should be added

5. Click **Add**

### Add iOS-Specific Files

1. Right-click on the project and select **Add Files to "BetterTimer"**

2. Navigate to the `iOS/` folder

3. Select all files:
   - BetterTimerApp.swift
   - TimersListView.swift
   - TimerDetailView.swift
   - AddTimerView.swift

4. Options:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ Select **iOS target only**

5. Click **Add**

### Remove Default Files

Delete these default files Xcode created (they're replaced by our files):
- `ContentView.swift`
- `BetterTimerApp.swift` (the default one, if present)

### Configure iOS Capabilities

1. Select the **project** in Project Navigator (blue icon at top)

2. Select the **iOS target** under Targets

3. Go to **Signing & Capabilities** tab

4. Click **+ Capability** and add:

   **App Groups:**
   - Click **+ App Groups** button under the section
   - Add: `group.com.yourteam.better-timer` (must match Config.swift)
   - Ensure checkbox is checked

   **iCloud:**
   - Check **CloudKit**
   - Click **+** under Containers
   - Add: `iCloud.com.yourteam.better-timer` (must match Config.swift)

   **Background Modes:**
   - Check ☑️ **Background fetch**
   - Check ☑️ **Remote notifications**

   **Push Notifications:**
   - Just enable it (no additional configuration needed)

### Configure Info.plist

1. Select `Info.plist` in Project Navigator

2. Add new entry:
   - Right-click in the list → **Add Row**
   - Key: **Permitted background task scheduler identifiers** (or `BGTaskSchedulerPermittedIdentifiers`)
   - Type: Array
   - Add item 0: `com.yourteam.better-timer.refresh`

## Step 3: Add macOS Target

1. Select **File → New → Target** (or press ⌃⌘N)

2. Select **macOS** tab → **App** template → **Next**

3. Configure:
   - **Product Name:** `BetterTimer-macOS`
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - Click **Finish**

4. When prompted, click **Activate** to make it the active scheme

### Add Files to macOS Target

1. Right-click on the project → **Add Files to "BetterTimer"**

2. Add **Shared/** files (same as iOS):
   - Select all files in Shared folder
   - ✅ Check **macOS target**
   - Click **Add**

3. Add **macOS/** specific files:
   - BetterTimerMacApp.swift
   - MenuBarView.swift
   - ✅ Check **macOS target only**
   - Click **Add**

### Configure macOS Capabilities

1. Select **BetterTimer-macOS** target

2. Go to **Signing & Capabilities**

3. Add:
   - **App Groups:** `group.com.yourteam.better-timer`
   - **iCloud:** with CloudKit container `iCloud.com.yourteam.better-timer`

## Step 4: Add watchOS Target

1. Select **File → New → Target**

2. Select **watchOS** tab → **App** template → **Next**

3. Configure:
   - **Product Name:** `BetterTimer-watchOS`
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - Click **Finish**

4. Click **Activate** when prompted

### Add Files to watchOS Target

1. Add **Shared/** files:
   - Right-click project → **Add Files**
   - Select Shared folder files
   - ✅ Check **watchOS target**
   - Note: Some iOS-specific features will be excluded via `#if` directives

2. Add **watchOS/** specific files:
   - BetterTimerWatchApp.swift
   - TimersListView.swift
   - TimerDetailView.swift
   - AddTimerView.swift
   - ✅ Check **watchOS target only**

### Configure watchOS Capabilities

1. Select **BetterTimer-watchOS** target

2. Go to **Signing & Capabilities**

3. Add:
   - **App Groups:** `group.com.yourteam.better-timer`
   - **iCloud:** with CloudKit container (if needed)
   - **App Intents:** for Siri/Shortcuts support

## Step 5: Add Test Target

Tests should already exist, but to add test files:

1. Right-click **Tests** group in Project Navigator

2. **Add Files to "BetterTimer"**

3. Navigate to `Tests/` folder and add:
   - TimerEngineTests.swift
   - TimerStoreTests.swift

4. Ensure test target is checked

## Step 6: Build and Run

### iOS App

1. Select **BetterTimer** scheme (or BetterTimer-iOS)
2. Choose an iOS Simulator or connected device
3. Press **⌘R** to build and run

**First Launch:** The app will:
- Request notification permissions
- Validate configuration (check Console for warnings)
- Attempt to sync with CloudKit (if configured)

### macOS App

1. Select **BetterTimer-macOS** scheme
2. Choose **My Mac** as destination
3. Press **⌘R** to build and run

The app will appear in your menu bar.

### watchOS App

1. Select **BetterTimer-watchOS** scheme
2. Choose an Apple Watch Simulator
3. Press **⌘R** to build and run

**Note:** For best results, test on physical Apple Watch.

### Running Tests

1. Select any scheme
2. Press **⌘U** to run all tests
3. View results in Test Navigator (⌘6)

## Step 7: CloudKit Setup (Optional but Recommended)

For cross-device sync to work:

1. **Create CloudKit Container:**
   - Go to [developer.apple.com](https://developer.apple.com)
   - Certificates, Identifiers & Profiles
   - CloudKit Containers
   - Create container: `iCloud.com.yourteam.better-timer`

2. **Enable iCloud in targets** (already done in Step 2-4)

3. **Test on device** (CloudKit doesn't work well in simulator)

See [ICLOUD_SETUP.md](ICLOUD_SETUP.md) for detailed CloudKit configuration.

## Step 8: Troubleshooting

### Build Errors

**"Cannot find 'Config' in scope"**
- Ensure Config.swift is added to all targets
- Check File Inspector → Target Membership

**"No such module 'CloudKit'"**
- Ensure iCloud capability is enabled
- Check that you're building for correct platform

**"AppGroup" not found**
- This was removed - should use Config.appGroupIdentifier
- Check that all files are using updated imports

### Runtime Issues

**"CloudKit is not available"**
- Sign into iCloud on device (Settings → [Your Name])
- Enable iCloud Drive
- Check capability configuration

**Timers not persisting**
- Verify App Group is configured correctly
- Check Console logs for save/load errors
- Ensure App Group ID matches Config.swift

**Live Activities not showing (iOS)**
- Only works on iOS 16.1+ physical devices
- Check notification permissions
- Verify Live Activities are enabled in Settings

### Signing Issues

**"Provisioning profile doesn't include App Groups"**
- Go to developer.apple.com
- Create new provisioning profile with App Groups enabled
- Download and install in Xcode

**"The bundle identifier cannot be used"**
- Change bundle identifier in project settings
- Update Config.swift accordingly

## Advanced Configuration

### Custom Bundle Identifiers

If you need different bundle IDs:

1. Select target → General tab
2. Change **Bundle Identifier**
3. Update Config.swift to match
4. Update CloudKit container to match

### Disabling Features

To disable CloudKit sync:
```swift
let store = TimerStore(enableCloudSync: false)
let controller = TimerController(store: store)
```

To remove Live Activities:
- Remove ActivityKit imports
- Remove Live Activity code (marked with `#if canImport(ActivityKit)`)

### Adding More Platforms

To add iPad-specific layouts:
- Create iPad-specific views
- Use `@Environment(\.horizontalSizeClass)` for adaptive layouts

## Next Steps

1. **Test thoroughly** on all platforms
2. **Configure CloudKit** for production
3. **Add app icons** for each target
4. **Create screenshots** for App Store
5. **Archive and distribute** via TestFlight

See [TestingAndReleaseGuide.md](TestingAndReleaseGuide.md) for release process.

## Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [App Intents Guide](https://developer.apple.com/documentation/appintents)
- [ActivityKit Documentation](https://developer.apple.com/documentation/activitykit)

---

**Need Help?** File an issue on GitHub or check existing documentation files.
