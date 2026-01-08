//
//  CloudKitSyncManager.swift
//  BetterTimer
//
//  Manages synchronization of timers with CloudKit/iCloud
//

import CloudKit
import Combine
import Foundation

public final class CloudKitSyncManager: ObservableObject {
    public static let shared = CloudKitSyncManager()

    @Published public private(set) var isSyncing = false
    @Published public private(set) var syncError: Error?
    @Published public private(set) var isCloudKitAvailable = false

    private let container: CKContainer
    private let database: CKDatabase
    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.container = CKContainer(identifier: Config.cloudKitContainerIdentifier)
        self.database = container.privateCloudDatabase

        checkCloudKitAvailability()
        setupSubscriptions()
    }

    // MARK: - CloudKit Availability

    private func checkCloudKitAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if let error {
                    Config.cloudKitLogger.error("CloudKit account status check failed: \(error.localizedDescription)")
                    self?.isCloudKitAvailable = false
                    return
                }

                switch status {
                case .available:
                    self?.isCloudKitAvailable = true
                    Config.cloudKitLogger.info("CloudKit is available")
                case .noAccount:
                    Config.cloudKitLogger.warning("No iCloud account signed in")
                    self?.isCloudKitAvailable = false
                case .restricted:
                    Config.cloudKitLogger.warning("CloudKit is restricted")
                    self?.isCloudKitAvailable = false
                case .couldNotDetermine:
                    Config.cloudKitLogger.warning("Could not determine CloudKit status")
                    self?.isCloudKitAvailable = false
                case .temporarilyUnavailable:
                    Config.cloudKitLogger.warning("CloudKit is temporarily unavailable")
                    self?.isCloudKitAvailable = false
                @unknown default:
                    Config.cloudKitLogger.warning("Unknown CloudKit status")
                    self?.isCloudKitAvailable = false
                }
            }
        }
    }

    // MARK: - Subscriptions

    private func setupSubscriptions() {
        // Set up a subscription to get notified of changes
        let subscription = CKQuerySubscription(
            recordType: Config.timerRecordType,
            predicate: NSPredicate(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification

        database.save(subscription) { [weak self] _, error in
            if let error = error as? CKError {
                // Subscription already exists is OK
                if error.code != .serverRejectedRequest {
                    Config.cloudKitLogger.error("Failed to create subscription: \(error.localizedDescription)")
                }
            } else if error == nil {
                Config.cloudKitLogger.info("CloudKit subscription created successfully")
            }
        }
    }

    // MARK: - Fetch Timers

    public func fetchTimers() async throws -> [TimerEntry] {
        guard isCloudKitAvailable else {
            throw CloudKitError.notAvailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            isSyncing = true

            let query = CKQuery(recordType: Config.timerRecordType, predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: Config.maxTimers) { result in
                DispatchQueue.main.async {
                    self.isSyncing = false

                    switch result {
                    case .success(let queryResult):
                        let timers = queryResult.matchResults.compactMap { _, result -> TimerEntry? in
                            switch result {
                            case .success(let record):
                                return self.timerEntry(from: record)
                            case .failure(let error):
                                Config.cloudKitLogger.error("Failed to fetch record: \(error.localizedDescription)")
                                return nil
                            }
                        }
                        Config.cloudKitLogger.info("Fetched \(timers.count) timers from CloudKit")
                        continuation.resume(returning: timers)

                    case .failure(let error):
                        Config.cloudKitLogger.error("Failed to fetch timers: \(error.localizedDescription)")
                        self.syncError = error
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    // MARK: - Save Timer

    public func saveTimer(_ timer: TimerEntry) async throws {
        guard isCloudKitAvailable else {
            throw CloudKitError.notAvailable
        }

        let record = ckRecord(from: timer)

        return try await withCheckedThrowingContinuation { continuation in
            isSyncing = true

            database.save(record) { savedRecord, error in
                DispatchQueue.main.async {
                    self.isSyncing = false

                    if let error {
                        Config.cloudKitLogger.error("Failed to save timer: \(error.localizedDescription)")
                        self.syncError = error
                        continuation.resume(throwing: error)
                    } else {
                        Config.cloudKitLogger.info("Saved timer: \(timer.title)")
                        continuation.resume()
                    }
                }
            }
        }
    }

    // MARK: - Save Multiple Timers

    public func saveTimers(_ timers: [TimerEntry]) async throws {
        guard isCloudKitAvailable else {
            throw CloudKitError.notAvailable
        }

        let records = timers.map { ckRecord(from: $0) }

        return try await withCheckedThrowingContinuation { continuation in
            isSyncing = true

            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInitiated

            operation.modifyRecordsResultBlock = { result in
                DispatchQueue.main.async {
                    self.isSyncing = false

                    switch result {
                    case .success:
                        Config.cloudKitLogger.info("Saved \(timers.count) timers to CloudKit")
                        continuation.resume()
                    case .failure(let error):
                        Config.cloudKitLogger.error("Failed to save timers: \(error.localizedDescription)")
                        self.syncError = error
                        continuation.resume(throwing: error)
                    }
                }
            }

            database.add(operation)
        }
    }

    // MARK: - Delete Timer

    public func deleteTimer(id: UUID) async throws {
        guard isCloudKitAvailable else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: id.uuidString)

        return try await withCheckedThrowingContinuation { continuation in
            isSyncing = true

            database.delete(withRecordID: recordID) { _, error in
                DispatchQueue.main.async {
                    self.isSyncing = false

                    if let error {
                        Config.cloudKitLogger.error("Failed to delete timer: \(error.localizedDescription)")
                        self.syncError = error
                        continuation.resume(throwing: error)
                    } else {
                        Config.cloudKitLogger.info("Deleted timer with ID: \(id)")
                        continuation.resume()
                    }
                }
            }
        }
    }

    // MARK: - Record Conversion

    private func ckRecord(from timer: TimerEntry) -> CKRecord {
        let recordID = CKRecord.ID(recordName: timer.id.uuidString)
        let record = CKRecord(recordType: Config.timerRecordType, recordID: recordID)

        record["title"] = timer.title as CKRecordValue
        record["totalSeconds"] = timer.totalSeconds as CKRecordValue
        record["remainingSeconds"] = timer.remainingSeconds as CKRecordValue
        record["state"] = timer.state.rawValue as CKRecordValue
        record["createdAt"] = timer.createdAt as CKRecordValue

        return record
    }

    private func timerEntry(from record: CKRecord) -> TimerEntry? {
        guard
            let title = record["title"] as? String,
            let totalSeconds = record["totalSeconds"] as? Int,
            let remainingSeconds = record["remainingSeconds"] as? Int,
            let stateRaw = record["state"] as? String,
            let state = TimerState(rawValue: stateRaw),
            let createdAt = record["createdAt"] as? Date,
            let id = UUID(uuidString: record.recordID.recordName)
        else {
            Config.cloudKitLogger.error("Failed to parse timer from CloudKit record")
            return nil
        }

        return TimerEntry(
            id: id,
            title: title,
            totalSeconds: totalSeconds,
            remainingSeconds: remainingSeconds,
            state: state,
            createdAt: createdAt
        )
    }

    // MARK: - Sync

    /// Performs a full sync: fetches from CloudKit and returns timers
    /// Use this when app launches or comes to foreground
    public func sync() async throws -> [TimerEntry] {
        try await fetchTimers()
    }

    /// Handle remote CloudKit notification
    /// Call this from your app delegate when receiving CloudKit notifications
    public func handleRemoteNotification() {
        Task {
            do {
                _ = try await fetchTimers()
                Config.cloudKitLogger.info("Processed remote CloudKit notification")
            } catch {
                Config.cloudKitLogger.error("Failed to handle remote notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Errors

public enum CloudKitError: LocalizedError {
    case notAvailable

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        }
    }
}
