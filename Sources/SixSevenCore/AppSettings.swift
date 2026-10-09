public enum AppTheme: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark
}

public struct AppSettings: Codable, Equatable, Sendable {
    public var soundEffectsEnabled: Bool
    public var motionControlEnabled: Bool
    public var theme: AppTheme

    public static let defaults = AppSettings()

    public init(
        soundEffectsEnabled: Bool = true,
        motionControlEnabled: Bool = false,
        theme: AppTheme = .system
    ) {
        self.soundEffectsEnabled = soundEffectsEnabled
        self.motionControlEnabled = motionControlEnabled
        self.theme = theme
    }

    private enum CodingKeys: String, CodingKey {
        case soundEffectsEnabled
        case motionControlEnabled
        case theme
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soundEffectsEnabled = try container.decode(Bool.self, forKey: .soundEffectsEnabled)
        motionControlEnabled = try container.decode(Bool.self, forKey: .motionControlEnabled)
        theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .system
    }
}
