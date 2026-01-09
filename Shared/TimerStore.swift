import Foundation
import Combine

public final class TimerStore: ObservableObject {
    private let timersKey = "timers"
    private let lastSyncKey = "lastSyncDate"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults: UserDefaults
    private let cloudKitSync: CloudKitSyncManager?
    private let enableCloudSync: Bool

    @Published public private(set) var isSyncing = false
    @Published public private(set) var lastSyncDate: Date?

    public init(
        userDefaults: UserDefaults? = nil,
        appGroupIdentifier: String = Config.appGroupIdentifier,
        enableCloudSync: Bool = true
    ) {
        self.enableCloudSync = enableCloudSync
        self.cloudKitSync = enableCloudSync ? CloudKitSyncManager.shared : nil

        if let userDefaults {
            self.userDefaults = userDefaults
        } else if let defaults = UserDefaults(suiteName: appGroupIdentifier) {
            self.userDefaults = defaults
        } else {
            Config.logger.warning("Failed to create UserDefaults with app group, falling back to standard")
            self.userDefaults = .standard
        }

        if let lastSync = userDefaults?.object(forKey: lastSyncKey) as? Date {
            self.lastSyncDate = lastSync
        }
    }

    // MARK: - Local Storage

    public func loadTimers() -> [TimerEntry] {
        guard let data = userDefaults.data(forKey: timersKey) else {
            return []
        }

        do {
            return try decoder.decode([TimerEntry].self, from: data)
        } catch {
            Config.logger.error("Failed to decode timers: \(error.localizedDescription)")
            return []
        }
    }

    public func saveTimers(_ timers: [TimerEntry]) {
        do {
            let data = try encoder.encode(timers)
            userDefaults.set(data, forKey: timersKey)
            Config.logger.info("Saved \(timers.count) timers to local storage")
        } catch {
            Config.logger.error("Failed to encode timers: \(error.localizedDescription)")
        }
    }

    // MARK: - CloudKit Sync

    /// Syncs timers with CloudKit
    /// Returns merged timers from both local and cloud
    public func syncWithCloud() async -> [TimerEntry] {
        guard enableCloudSync, let cloudKitSync = cloudKitSync, cloudKitSync.isCloudKitAvailable else {
            Config.logger.info("CloudKit sync disabled or unavailable, using local timers only")
            return loadTimers()
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            // 1. Load local timers
            let localTimers = loadTimers()
            Config.logger.info("Loaded \(localTimers.count) local timers")

            // 2. Fetch cloud timers
            let cloudTimers = try await cloudKitSync.fetchTimers()
            Config.logger.info("Fetched \(cloudTimers.count) cloud timers")

            // 3. Merge local and cloud timers (cloud takes precedence for conflicts)
            let mergedTimers = mergeTimers(local: localTimers, cloud: cloudTimers)
            Config.logger.info("Merged into \(mergedTimers.count) timers")

            // 4. Save merged timers locally
            saveTimers(mergedTimers)

            // 5. Update last sync date
            lastSyncDate = Date()
            userDefaults.set(lastSyncDate, forKey: lastSyncKey)

            return mergedTimers
        } catch {
            Config.logger.error("CloudKit sync failed: \(error.localizedDescription)")
            // Return local timers on sync failure
            return loadTimers()
        }
    }

    /// Pushes local timers to CloudKit
    public func pushToCloud(_ timers: [TimerEntry]) async {
        guard enableCloudSync, let cloudKitSync = cloudKitSync, cloudKitSync.isCloudKitAvailable else {
            return
        }

        do {
            try await cloudKitSync.saveTimers(timers)
            lastSyncDate = Date()
            userDefaults.set(lastSyncDate, forKey: lastSyncKey)
            Config.logger.info("Pushed \(timers.count) timers to CloudKit")
        } catch {
            Config.logger.error("Failed to push timers to CloudKit: \(error.localizedDescription)")
        }
    }

    /// Deletes a timer from CloudKit
    public func deleteFromCloud(id: UUID) async {
        guard enableCloudSync, let cloudKitSync = cloudKitSync, cloudKitSync.isCloudKitAvailable else {
            return
        }

        do {
            try await cloudKitSync.deleteTimer(id: id)
            Config.logger.info("Deleted timer from CloudKit: \(id)")
        } catch {
            Config.logger.error("Failed to delete timer from CloudKit: \(error.localizedDescription)")
        }
    }

    // MARK: - Merging Logic

    private func mergeTimers(local: [TimerEntry], cloud: [TimerEntry]) -> [TimerEntry] {
        var timerDict: [UUID: TimerEntry] = [:]

        // First add all local timers
        for timer in local {
            timerDict[timer.id] = timer
        }

        // Then merge/overwrite with cloud timers
        // Cloud takes precedence based on createdAt being newer or having more recent state updates
        for cloudTimer in cloud {
            if let localTimer = timerDict[cloudTimer.id] {
                // Timer exists in both - use the one with more recent updates
                // For simplicity, we use cloud as source of truth
                timerDict[cloudTimer.id] = cloudTimer
            } else {
                // Timer only exists in cloud - add it
                timerDict[cloudTimer.id] = cloudTimer
            }
        }

        return Array(timerDict.values).sorted { $0.createdAt > $1.createdAt }
    }
}

