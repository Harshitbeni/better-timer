//
//  Config.swift
//  BetterTimer
//
//  Centralized configuration for app identifiers and settings
//

import Foundation
import os.log

/// Centralized configuration for BetterTimer
enum Config {
    // MARK: - App Identifiers

    /// The App Group identifier used for sharing data between targets
    /// Update this to match your team's App Group ID
    static let appGroupIdentifier = "group.com.example.better-timer"

    /// Background task identifier for iOS background refresh
    /// Update this to match your bundle identifier prefix
    static let backgroundTaskIdentifier = "com.example.better-timer.refresh"

    /// Timer engine dispatch queue identifier
    static let timerQueueIdentifier = "com.example.better-timer.engine"

    /// CloudKit container identifier for iCloud sync
    /// Update this to match your CloudKit container ID
    static let cloudKitContainerIdentifier = "iCloud.com.example.better-timer"

    // MARK: - CloudKit Configuration

    /// CloudKit record type for timer entries
    static let timerRecordType = "TimerEntry"

    /// CloudKit zone name for custom zone (if using)
    static let customZoneName = "TimersZone"

    // MARK: - App Settings

    /// Maximum number of timers allowed
    static let maxTimers = 50

    /// Minimum timer duration in seconds
    static let minTimerDuration = 1

    /// Maximum timer duration in seconds (24 hours)
    static let maxTimerDuration = 86400

    /// Default timer duration in seconds (5 minutes)
    static let defaultTimerDuration = 300

    // MARK: - Logging

    /// Main logger for the app
    static let logger = Logger(subsystem: "com.example.better-timer", category: "BetterTimer")

    /// Logger for CloudKit operations
    static let cloudKitLogger = Logger(subsystem: "com.example.better-timer", category: "CloudKit")

    /// Logger for timer engine operations
    static let timerLogger = Logger(subsystem: "com.example.better-timer", category: "TimerEngine")

    /// Logger for notifications
    static let notificationLogger = Logger(subsystem: "com.example.better-timer", category: "Notifications")
}

// MARK: - Configuration Validation

extension Config {
    /// Validates that all identifiers are properly configured
    /// Call this at app launch to ensure configuration is correct
    static func validate() {
        let placeholders = [
            appGroupIdentifier.contains("com.example"),
            cloudKitContainerIdentifier.contains("com.example")
        ]

        if placeholders.contains(true) {
            logger.warning("⚠️ Configuration contains example identifiers. Please update Config.swift with your team's identifiers.")
        }

        logger.info("BetterTimer configuration loaded")
    }
}
