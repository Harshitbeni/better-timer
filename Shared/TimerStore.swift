import Foundation

public enum AppGroup {
    public static let containerIdentifier = "group.com.example.better-timer"
}

public final class TimerStore {
    private let timersKey = "timers"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults: UserDefaults

    public init(
        userDefaults: UserDefaults? = nil,
        appGroupIdentifier: String = AppGroup.containerIdentifier
    ) {
        if let userDefaults {
            self.userDefaults = userDefaults
        } else if let defaults = UserDefaults(suiteName: appGroupIdentifier) {
            self.userDefaults = defaults
        } else {
            self.userDefaults = .standard
        }
    }

    public func loadTimers() -> [TimerEntry] {
        guard let data = userDefaults.data(forKey: timersKey) else {
            return []
        }

        do {
            return try decoder.decode([TimerEntry].self, from: data)
        } catch {
            return []
        }
    }

    public func saveTimers(_ timers: [TimerEntry]) {
        do {
            let data = try encoder.encode(timers)
            userDefaults.set(data, forKey: timersKey)
        } catch {
            // In a production app this should be logged
        }
    }
}
