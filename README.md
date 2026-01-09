# BetterTimer

A beautiful, native multi-platform countdown timer app for Apple's ecosystem with iCloud sync.

<div align="center">

**Available on iOS • macOS • watchOS**

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%2016.1+%20%7C%20macOS%2013.0+%20%7C%20watchOS%209.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

</div>

## ✨ Features

### Core Features
- 🕐 **Multiple Countdown Timers** - Create and manage unlimited timers
- ⏱️ **Precise Timing** - Accurate countdown with second-level precision
- 🎯 **Timer Controls** - Start, pause, reset, and delete timers
- 📱 **Native UI** - Platform-specific SwiftUI interfaces for each device
- 💾 **Local Persistence** - Timers saved locally using App Groups

### Cross-Platform Sync ☁️
- **iCloud Sync** - Automatically sync timers across all your Apple devices
- **CloudKit Integration** - Secure, private cloud storage
- **Offline Support** - Works perfectly without internet, syncs when available
- **Conflict Resolution** - Smart merging of timers from multiple devices

### iOS Features
- 🎪 **Live Activities** - See timer progress on Lock Screen and Dynamic Island (iOS 16.1+)
- 🔔 **Notifications** - Get notified when timers complete
- 📲 **Background Refresh** - Timers update in background
- 🎨 **Modern Design** - Beautiful iOS-native interface with progress rings

### macOS Features
- 📍 **Menu Bar App** - Quick access to timers from menu bar
- 🖥️ **Native macOS UI** - Designed for desktop experience

### watchOS Features
- ⌚ **Full Watch App** - Complete timer management on Apple Watch
- 📳 **Haptic Feedback** - Tactile feedback for all actions
- 🏃 **Standalone** - Works independently without iPhone

### Siri & Shortcuts
- 🗣️ **Siri Integration** - "Hey Siri, start my workout timer"
- ⚡ **Shortcuts Support** - Automate timers with iOS Shortcuts app
- 🎯 **App Intents** - Create, start, pause, and reset timers via Shortcuts

## 🏗️ Architecture

### Modern Swift Design
- **SwiftUI** - Declarative UI framework for all platforms
- **Combine** - Reactive programming for state management
- **Async/Await** - Modern concurrency for CloudKit operations
- **CloudKit** - Apple's cloud database for cross-device sync

### Code Structure
```
better-timer/
├── Shared/                   # Code shared across all platforms
│   ├── Config.swift         # Centralized configuration
│   ├── TimerModel.swift     # Data models
│   ├── TimerEngine.swift    # Core timer logic
│   ├── TimerStore.swift     # Persistence & CloudKit sync
│   ├── TimerController.swift # Main coordinator
│   ├── CloudKitSyncManager.swift # iCloud sync
│   ├── NotificationManager.swift # Local notifications
│   └── ...
├── iOS/                     # iOS-specific code
│   ├── BetterTimerApp.swift
│   ├── TimersListView.swift
│   ├── TimerDetailView.swift
│   └── AddTimerView.swift
├── macOS/                   # macOS-specific code
│   └── BetterTimerMacApp.swift
├── watchOS/                 # watchOS-specific code
│   ├── BetterTimerWatchApp.swift
│   └── ...
└── Tests/                   # Unit tests
    ├── TimerEngineTests.swift
    └── TimerStoreTests.swift
```

### Key Components

**TimerEngine** - Thread-safe timer management using `DispatchSourceTimer`
- Handles countdown logic
- State management (idle, running, paused, completed)
- Tick notifications

**TimerStore** - Dual-layer persistence
- Local storage via `UserDefaults` with App Groups
- Cloud storage via CloudKit for cross-device sync
- Smart merging of local and cloud data

**CloudKitSyncManager** - iCloud synchronization
- Automatic sync on app launch
- Push changes in background
- Handle remote notifications
- Conflict resolution

**TimerController** - Main coordinator
- Connects engine, store, and UI
- Manages Live Activities (iOS)
- Schedules notifications
- Handles haptic feedback

## 🚀 Getting Started

### Prerequisites
- macOS 13.0+ with Xcode 14.0+
- Apple Developer account (for CloudKit and device testing)
- iCloud account for sync features

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/better-timer.git
   cd better-timer
   ```

2. **Configure identifiers**

   Open `Shared/Config.swift` and update:
   ```swift
   static let appGroupIdentifier = "group.com.yourteam.better-timer"
   static let cloudKitContainerIdentifier = "iCloud.com.yourteam.better-timer"
   // ... update all identifiers
   ```

3. **Create Xcode project**

   See [PROJECT_SETUP.md](PROJECT_SETUP.md) for detailed instructions on:
   - Creating Xcode project from source files
   - Adding platform targets (iOS, macOS, watchOS)
   - Configuring capabilities and signing

4. **Set up iCloud sync (optional)**

   See [ICLOUD_SETUP.md](ICLOUD_SETUP.md) for:
   - CloudKit container creation
   - Capability configuration
   - Testing sync across devices

5. **Build and run**
   ```
   ⌘B to build
   ⌘R to run
   ⌘U to run tests
   ```

## 📱 Usage

### Creating Timers
- **iOS/watchOS:** Tap the **+** button
- **macOS:** Click menu bar icon → **Add Timer**
- Enter title and duration
- Timer starts in idle state

### Managing Timers
- **Start:** Begin countdown
- **Pause:** Freeze at current time
- **Reset:** Return to full duration
- **Delete:** Swipe left (iOS) or context menu

### Siri & Shortcuts
Create shortcuts like:
- "Start my workout timer"
- "Pause all timers"
- "Create a 5-minute break timer"

## 🧪 Testing

### Run Unit Tests
```bash
# In Xcode: Press ⌘U
# Or select: Product → Test
```

**Test Coverage:**
- Timer countdown logic
- Pause/resume functionality
- Persistence round-trip
- State management

### Manual Testing Checklist
- [ ] Create timer with custom name/duration
- [ ] Start, pause, resume timer
- [ ] Reset timer
- [ ] Delete timer
- [ ] App restart (persistence)
- [ ] Notifications on completion
- [ ] Live Activities (iOS)
- [ ] iCloud sync across devices
- [ ] Offline mode operation

See [TestingAndReleaseGuide.md](TestingAndReleaseGuide.md) for full checklist.

## 🔧 Configuration

### App Identifiers
All identifiers are centralized in `Shared/Config.swift`:
- App Group identifier
- CloudKit container identifier
- Background task identifier
- Logging subsystems

### Feature Flags
Disable CloudKit sync for testing:
```swift
let store = TimerStore(enableCloudSync: false)
```

### Logging
Uses `os.log` unified logging:
```swift
Config.logger.info("General app logs")
Config.cloudKitLogger.info("CloudKit operations")
Config.timerLogger.info("Timer engine logs")
Config.notificationLogger.info("Notification logs")
```

View logs in Console.app filtered by subsystem.

## 📖 Documentation

- **[PROJECT_SETUP.md](PROJECT_SETUP.md)** - Detailed Xcode project setup
- **[ICLOUD_SETUP.md](ICLOUD_SETUP.md)** - CloudKit and iCloud configuration
- **[TestingAndReleaseGuide.md](TestingAndReleaseGuide.md)** - Testing and release process

## 🛠️ Development

### Code Quality
- ✅ No force unwraps or unsafe patterns
- ✅ Proper memory management with `[weak self]`
- ✅ Thread-safe design
- ✅ Comprehensive error handling and logging
- ✅ Platform-specific compilation directives

### Architecture Decisions
- **Thread Safety:** All timer operations on dedicated serial queue
- **Persistence:** Dual-layer (local + cloud) for reliability
- **Sync Strategy:** Cloud takes precedence in conflicts
- **State Management:** Combine for reactive updates
- **UI:** SwiftUI for modern, declarative interfaces

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with:
- SwiftUI for UI
- Combine for reactive programming
- CloudKit for cloud sync
- ActivityKit for Live Activities
- App Intents for Siri integration

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/better-timer/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/better-timer/discussions)

---

<div align="center">

**Made with ❤️ using Swift and SwiftUI**

[Report Bug](https://github.com/yourusername/better-timer/issues) · [Request Feature](https://github.com/yourusername/better-timer/issues)

</div>
