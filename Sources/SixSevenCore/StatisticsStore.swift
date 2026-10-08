import Foundation

public protocol StatisticsStore: Sendable {
    func load() async throws -> Statistics
    func save(_ statistics: Statistics) async throws
}

public actor UserDefaultsStatisticsStore: StatisticsStore {
    private static let key = "sixseven.statistics"
    private let defaults: UserDefaults

    public init(suiteName: String? = nil) {
        self.defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    public func load() async throws -> Statistics {
        guard let data = defaults.data(forKey: Self.key) else {
            return .empty
        }

        return try JSONDecoder().decode(Statistics.self, from: data)
    }

    public func save(_ statistics: Statistics) async throws {
        let data = try JSONEncoder().encode(statistics)
        defaults.set(data, forKey: Self.key)
    }
}
