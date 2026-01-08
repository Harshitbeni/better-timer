# iCloud / CloudKit Setup Guide

BetterTimer now supports full cross-platform sync using iCloud and CloudKit. Your timers will automatically sync across all your Apple devices (iPhone, iPad, Mac, Apple Watch).

## Prerequisites

- Active Apple Developer account
- iCloud account signed in on your Mac and test devices
- Xcode 14.0 or later

## Setup Instructions

### 1. Configure App Identifiers in Config.swift

Open `Shared/Config.swift` and update the following identifiers with your team-specific values:

```swift
// Replace "com.example" with your team identifier or bundle ID prefix
static let appGroupIdentifier = "group.com.yourteam.better-timer"
static let backgroundTaskIdentifier = "com.yourteam.better-timer.refresh"
static let timerQueueIdentifier = "com.yourteam.better-timer.engine"
static let cloudKitContainerIdentifier = "iCloud.com.yourteam.better-timer"
```

### 2. Create CloudKit Container

1. Sign in to [Apple Developer Portal](https://developer.apple.com)
2. Go to **Certificates, Identifiers & Profiles**
3. Select **CloudKit Containers** from the left sidebar
4. Click the **+** button to create a new container
5. Enter identifier: `iCloud.com.yourteam.better-timer` (must match Config.swift)
6. Click **Continue** and **Register**

### 3. Configure Xcode Project Capabilities

For **each target** (iOS, macOS, watchOS), enable the following capabilities:

#### Required Capabilities:

**App Groups:**
1. Select your target in Xcode
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add **App Groups**
4. Click **+** under App Groups and add: `group.com.yourteam.better-timer`
5. Ensure the checkbox is selected

**iCloud:**
1. Click **+ Capability** and add **iCloud**
2. Check **CloudKit**
3. Click **+** under Containers
4. Select or add: `iCloud.com.yourteam.better-timer`
5. Ensure it matches your CloudKit container from step 2

**Background Modes (iOS only):**
1. Click **+ Capability** and add **Background Modes**
2. Check the following:
   - ☑️ **Background fetch**
   - ☑️ **Remote notifications**

**Push Notifications (iOS only):**
1. Click **+ Capability** and add **Push Notifications**
2. This enables CloudKit remote notifications

### 4. Configure Info.plist (iOS target)

Add background task registration to your iOS target's `Info.plist`:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.yourteam.better-timer.refresh</string>
</array>
```

Or in Xcode:
1. Select Info.plist
2. Add new entry: **Permitted background task scheduler identifiers** (Array)
3. Add item: `com.yourteam.better-timer.refresh`

### 5. CloudKit Dashboard Configuration (Optional)

For production apps, you may want to configure your CloudKit schema:

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Select your container: `iCloud.com.yourteam.better-timer`
3. Select **Schema** → **Record Types**
4. The app will automatically create the `TimerEntry` record type on first use

#### TimerEntry Schema:
The following fields are automatically created by the app:
- `title` (String)
- `totalSeconds` (Int64)
- `remainingSeconds` (Int64)
- `state` (String)
- `createdAt` (Date/Time)

### 6. Testing CloudKit Sync

#### Development Testing:
1. Build and run on a device (CloudKit doesn't work well in simulator)
2. Sign in with your iCloud account in Settings
3. Create a timer in the app
4. Check Console logs for CloudKit sync messages
5. Install app on second device with same iCloud account
6. Verify timer appears automatically

#### Verify Logs:
Look for these log messages in Xcode Console:
```
BetterTimer: CloudKit is available
CloudKit: Saved X timers to CloudKit
CloudKit: Fetched X timers from CloudKit
```

#### Common Issues:

**"CloudKit is not available":**
- Ensure iCloud account is signed in (Settings → [Your Name] → iCloud)
- Check that iCloud Drive is enabled
- Verify App Group and iCloud capabilities are properly configured

**"Failed to save timer":**
- Check CloudKit container identifier matches exactly
- Ensure you're testing on a physical device (not simulator)
- Verify Internet connection is active

**Timers not syncing:**
- Allow a few seconds for sync to complete
- Pull to refresh (if implemented in UI)
- Check that same iCloud account is signed in on all devices
- Verify CloudKit subscription was created (check logs)

### 7. Production Deployment

Before releasing to production:

1. **Deploy CloudKit Schema:**
   - Go to CloudKit Dashboard
   - Schema → Development → **Deploy to Production**
   - This is required before submitting to App Store

2. **Test with TestFlight:**
   - Archive and upload to App Store Connect
   - Distribute via TestFlight
   - Test with production CloudKit environment

3. **Monitor CloudKit Usage:**
   - CloudKit Dashboard → Analytics
   - Check request volume and errors

## How CloudKit Sync Works

### Automatic Sync:
- **App Launch:** Syncs with CloudKit automatically
- **Timer Changes:** Pushes updates to CloudKit in background
- **Remote Changes:** Receives push notifications when data changes on other devices

### Conflict Resolution:
- **Strategy:** Last Write Wins (cloud takes precedence)
- **Merge:** Local and cloud timers are merged by UUID
- **Offline Mode:** App works fully offline, syncs when connection restored

### Data Storage:
- **Local:** UserDefaults (via App Groups) - instant access
- **Cloud:** CloudKit Private Database - synced across devices
- **Persistence:** Both local and cloud for maximum reliability

## Privacy & Security

- All timer data is stored in **CloudKit Private Database**
- Data is **never** accessible to other users
- Data is encrypted in transit and at rest by Apple
- Only accessible when user is signed into their iCloud account
- Data belongs to the user and stored in their iCloud storage

## Disabling CloudKit Sync

To disable CloudKit sync for testing:

```swift
let store = TimerStore(enableCloudSync: false)
let controller = TimerController(store: store)
```

This will use only local storage without iCloud.

## Support

For CloudKit issues:
- Check [Apple CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- Review [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
- File issues on the GitHub repository

---

**Important:** Always test CloudKit functionality on physical devices. The iOS Simulator has limited CloudKit support and may not work correctly.
