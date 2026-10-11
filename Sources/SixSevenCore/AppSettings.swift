public enum AppTheme: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark
}

public enum CoinTheme: String, Codable, CaseIterable, Sendable {
    case illustrated
    case colorful
    case silver
    case classic
}

public enum BackgroundTheme: String, Codable, CaseIterable, Sendable {
    case automatic
    case colorfulOne
    case colorfulTwo
}

public struct AppSettings: Codable, Equatable, Sendable {
    public var soundEffectsEnabled: Bool
    public var motionControlEnabled: Bool
    public var theme: AppTheme
    public var coinTheme: CoinTheme
    public var backgroundTheme: BackgroundTheme

    public static let defaults = AppSettings()

    public init(
        soundEffectsEnabled: Bool = true,
        motionControlEnabled: Bool = false,
        theme: AppTheme = .system,
        coinTheme: CoinTheme = .illustrated,
        backgroundTheme: BackgroundTheme = .automatic
    ) {
        self.soundEffectsEnabled = soundEffectsEnabled
        self.motionControlEnabled = motionControlEnabled
        self.theme = theme
        self.coinTheme = coinTheme
        self.backgroundTheme = backgroundTheme
    }

    private enum CodingKeys: String, CodingKey {
        case soundEffectsEnabled
        case motionControlEnabled
        case theme
        case coinTheme
        case backgroundTheme
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soundEffectsEnabled = try container.decode(Bool.self, forKey: .soundEffectsEnabled)
        motionControlEnabled = try container.decode(Bool.self, forKey: .motionControlEnabled)
        theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .system
        coinTheme = try container.decodeIfPresent(CoinTheme.self, forKey: .coinTheme) ?? .illustrated
        backgroundTheme = try container.decodeIfPresent(BackgroundTheme.self, forKey: .backgroundTheme) ?? .automatic
    }
}
