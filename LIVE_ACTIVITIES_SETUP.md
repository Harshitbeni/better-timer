# Live Activities Setup & Troubleshooting Guide

This guide helps you set up and troubleshoot Live Activities for BetterTimer.

## What Are Live Activities?

Live Activities display real-time timer information on:
- **Lock Screen** - See your countdown without unlocking
- **Dynamic Island** (iPhone 14 Pro+) - Glanceable timer in the status bar area

## Requirements

- iOS 16.1 or later
- Physical iPhone (simulator support is limited)
- Xcode 14.1 or later

## Critical Setup Steps

### 1. Add Info.plist Configuration

**This is the #1 reason Live Activities don't work!**

The provided `iOS/Info.plist` file already includes this, but if you're creating your own:

1. In Xcode, select your **Info.plist** file
2. Right-click → **Add Row**
3. Add these keys:

```xml
NSSupportsLiveActivities = YES (Boolean)
NSSupportsLiveActivitiesFrequentUpdates = YES (Boolean)
```

**Without these keys, Live Activities will NEVER show up, even if all other code is correct.**

### 2. Import the Info.plist

If you haven't already:

1. In Xcode Project Navigator, right-click your iOS app folder
2. Select **Add Files to "BetterTimer"**
3. Navigate to `iOS/Info.plist`
4. **Important:** Ensure **only the iOS target** is checked
5. Click **Add**

### 3. Verify Capabilities

In your iOS target's **Signing & Capabilities** tab, ensure you have:

- ✅ **Push Notifications** (required for Live Activities)
- ✅ **Background Modes** with "Remote notifications" checked

### 4. Check Code Integration

The code is already integrated, but verify these files are in your project:

- `Shared/BetterTimerActivity.swift` - Activity attributes definition
- `Shared/BetterTimerLiveActivity.swift` - UI for Lock Screen and Dynamic Island
- `Shared/TimerController.swift` - Activity lifecycle management

## Testing Live Activities

### On Physical Device (Recommended)

1. **Build and run** on your iPhone (iOS 16.1+)
2. **Start a timer** from the app
3. **Lock your device** or press home button
4. You should see the timer on the Lock Screen

**For Dynamic Island (iPhone 14 Pro/Pro Max or later):**
- The timer will appear in the Dynamic Island
- Long press to see expanded view with progress bar

### On Simulator (Limited)

⚠️ **Live Activities have limited simulator support:**

- Lock Screen activities may not appear
- Dynamic Island won't work (requires special iPhone models)
- Console may show errors even with correct setup

**Best practice:** Always test on a real device before concluding something is broken.

## Troubleshooting

### Live Activity Not Appearing

**1. Check Info.plist**
```bash
# In your project, verify Info.plist contains:
NSSupportsLiveActivities = YES
```

**2. Check Device Settings**
- Go to Settings → [Your App Name]
- Ensure "Live Activities" toggle is ON

**3. Check iOS Version**
- Settings → General → About → iOS Version
- Must be 16.1 or later

**4. Check Xcode Console**

Look for these log messages:

✅ **Success:**
```
Live Activity started for timer: [Timer Name]
```

❌ **Failure:**
```
Failed to start Live Activity: [Error message]
```

Common error messages:

- **"Activities are not enabled"** → User disabled in Settings
- **"Unsupported"** → iOS version too old or simulator limitations
- **"Missing entitlement"** → Push Notifications capability not enabled

**5. Verify Notification Permissions**

Live Activities require notification permissions:

```swift
// App should request on first launch (already implemented)
NotificationManager.shared.requestAuthorizationIfNeeded()
```

Check in Settings → [App] → Notifications → Allow Notifications is ON

### Code-Level Debugging

Add debug logging to see what's happening:

**Check if activities are enabled:**
```swift
#if canImport(ActivityKit)
if #available(iOS 16.1, *) {
    let authInfo = ActivityAuthorizationInfo()
    print("Activities enabled: \(authInfo.areActivitiesEnabled)")
}
#endif
```

**Check activity state:**
```swift
// In TimerController.swift, the code already logs:
Config.logger.info("Live Activity started for timer: \(entry.title)")
```

View these logs in Xcode's Console (⌘⇧Y).

### Dynamic Island Not Showing

**Requirements:**
- iPhone 14 Pro, 14 Pro Max, 15 Pro, 15 Pro Max, or 16 Pro models
- iOS 16.1+
- Live Activity must be active

**If you have a supported device:**
1. Check Settings → Accessibility → Dynamic Island → Enable
2. Ensure "Show Live Activities" is ON
3. Restart the app and try again

### Lock Screen Not Showing

**Check these settings:**
- Settings → Face ID & Passcode → "Allow Access When Locked" → Today View and Search ON
- Settings → [App] → Live Activities → ON
- Device is actually locked (not just screen off)

### Simulator Issues

The simulator has many limitations:

- Dynamic Island never appears (requires specific hardware)
- Lock Screen activities may not render correctly
- ActivityKit may return "unsupported" errors

**Solution:** Test on a physical device.

## How Live Activities Work in BetterTimer

### Starting an Activity

When you start a timer:

1. `TimerController.start(timerID:)` is called
2. Checks if iOS 16.1+ and activities are enabled
3. Creates `BetterTimerAttributes` with timer info
4. Calls `Activity.request()` to start the Live Activity
5. Activity appears on Lock Screen / Dynamic Island

### Updating an Activity

Every timer tick (1 second):

1. `TimerEngine` calls `onTick` callback
2. `TimerController.handleTick()` is invoked
3. Updates activity with new `remainingSeconds`
4. UI refreshes in real-time on Lock Screen

### Ending an Activity

When timer completes or is reset:

1. `activity.end()` is called
2. Activity dismissed from Lock Screen
3. Cleanup: `liveActivity` and `activityID` set to `nil`

## Architecture

```
BetterTimerAttributes (immutable)
├── timerID: UUID
├── title: String
└── totalSeconds: Int

BetterTimerActivityState (dynamic)
├── remainingSeconds: Int  ← Updated every second
├── title: String
└── isRunning: Bool       ← Paused/Running status
```

The Live Activity UI reads from these and formats:
- Countdown timer (MM:SS)
- Progress bar (percentage complete)
- Status pill (Running/Paused)

## Best Practices

### Development

1. **Always test on device** for Live Activities
2. **Check console logs** for activity lifecycle events
3. **Use Debug → View Debugging → Show Live Activities** in Xcode

### Debugging

1. **Add breakpoints** in `requestLiveActivityIfNeeded()`
2. **Print `ActivityAuthorizationInfo`** to verify permissions
3. **Monitor `Activity<>.activityStateUpdates`** for state changes

### Production

1. **Handle permission denials gracefully** (already implemented)
2. **Provide fallback UI** for older iOS versions (handled with `#available`)
3. **Test on multiple iPhone models** (especially for Dynamic Island)

## Common Mistakes

❌ **Forgetting Info.plist key**
```xml
<!-- Without this, activities will NEVER work -->
<key>NSSupportsLiveActivities</key>
<true/>
```

❌ **Not requesting notification permissions**
```swift
// Required before Live Activities work
NotificationManager.shared.requestAuthorizationIfNeeded()
```

❌ **Testing only in simulator**
- Simulator has limited Live Activity support
- Always verify on real device

❌ **Not checking iOS version**
```swift
// Always wrap in version check
#if canImport(ActivityKit)
if #available(iOS 16.1, *) {
    // Live Activity code
}
#endif
```

## Verification Checklist

Before filing a bug report, verify:

- [ ] iOS 16.1+ on physical device
- [ ] `NSSupportsLiveActivities = YES` in Info.plist
- [ ] Push Notifications capability enabled
- [ ] Settings → [App] → Live Activities is ON
- [ ] Settings → [App] → Notifications → Allow Notifications is ON
- [ ] Console shows "Live Activity started" message
- [ ] Tested on physical device (not just simulator)

## Getting Help

If Live Activities still don't work after following this guide:

1. Check Xcode console for error messages
2. Verify all steps in this guide
3. Review `TimerController.swift:213-241` for activity request code
4. File an issue with:
   - iOS version
   - Device model
   - Console logs
   - Screenshot of app settings

## Additional Resources

- [Apple's Live Activities Documentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [ActivityKit Framework Reference](https://developer.apple.com/documentation/activitykit)
- [WWDC 2022: Meet ActivityKit](https://developer.apple.com/videos/play/wwdc2022/10184/)

---

**Quick Fix:** Most Live Activities issues are solved by adding `NSSupportsLiveActivities = YES` to Info.plist!
