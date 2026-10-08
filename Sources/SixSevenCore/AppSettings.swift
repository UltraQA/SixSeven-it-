public struct AppSettings: Codable, Equatable, Sendable {
    public var soundEffectsEnabled: Bool
    public var motionControlEnabled: Bool

    public static let defaults = AppSettings()

    public init(soundEffectsEnabled: Bool = true, motionControlEnabled: Bool = false) {
        self.soundEffectsEnabled = soundEffectsEnabled
        self.motionControlEnabled = motionControlEnabled
    }
}
