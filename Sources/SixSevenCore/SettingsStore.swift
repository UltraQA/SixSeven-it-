import Foundation

public protocol SettingsStore: Sendable {
    func load() async throws -> AppSettings
    func save(_ settings: AppSettings) async throws
}

public actor UserDefaultsSettingsStore: SettingsStore {
    private static let key = "sixseven.settings"
    private let defaults: UserDefaults

    public init(suiteName: String? = nil) {
        self.defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    public func load() async throws -> AppSettings {
        guard let data = defaults.data(forKey: Self.key) else {
            return .defaults
        }

        return try JSONDecoder().decode(AppSettings.self, from: data)
    }

    public func save(_ settings: AppSettings) async throws {
        let data = try JSONEncoder().encode(settings)
        defaults.set(data, forKey: Self.key)
    }
}
