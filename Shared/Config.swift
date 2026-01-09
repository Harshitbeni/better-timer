//
//  Config.swift
//  BetterTimer
//
//  Centralized configuration for app identifiers and settings
//

import Foundation
import os.log

/// Centralized configuration for BetterTimer
public enum Config {
    // MARK: - App Identifiers

    /// The App Group identifier used for sharing data between targets
    /// Update this to match your team's App Group ID
    public static let appGroupIdentifier = "group.com.harshitbeni.better-timer"

    /// Background task identifier for iOS background refresh
    /// Update this to match your bundle identifier prefix
    public static let backgroundTaskIdentifier = "com.harshitbeni.better-timer.refresh"

    /// Timer engine dispatch queue identifier
    public static let timerQueueIdentifier = "com.harshitbeni.better-timer.engine"

    /// CloudKit container identifier for iCloud sync
    /// Update this to match your CloudKit container ID
    public static let cloudKitContainerIdentifier = "iCloud.com.harshitbeni.better-timer"

    // MARK: - CloudKit Configuration

    /// CloudKit record type for timer entries
    public static let timerRecordType = "TimerEntry"

    /// CloudKit zone name for custom zone (if using)
    public static let customZoneName = "TimersZone"

    // MARK: - App Settings

    /// Maximum number of timers allowed
    public static let maxTimers = 50

    /// Minimum timer duration in seconds
    public static let minTimerDuration = 1

    /// Maximum timer duration in seconds (24 hours)
    public static let maxTimerDuration = 86400

    /// Default timer duration in seconds (5 minutes)
    public static let defaultTimerDuration = 300

    // MARK: - Logging

    /// Main logger for the app
    public static let logger = Logger(subsystem: "com.harshitbeni.better-timer", category: "BetterTimer")

    /// Logger for CloudKit operations
    public static let cloudKitLogger = Logger(subsystem: "com.harshitbeni.better-timer", category: "CloudKit")

    /// Logger for timer engine operations
    public static let timerLogger = Logger(subsystem: "com.harshitbeni.better-timer", category: "TimerEngine")

    /// Logger for notifications
    public static let notificationLogger = Logger(subsystem: "com.harshitbeni.better-timer", category: "Notifications")
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
