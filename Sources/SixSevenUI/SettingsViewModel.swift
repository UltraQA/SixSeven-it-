import Combine
import SixSevenCore

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public private(set) var settings: AppSettings = .defaults

    private let store: any SettingsStore
    private var loadTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?

    public init(store: any SettingsStore = UserDefaultsSettingsStore()) {
        self.store = store
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let loadedSettings = try await store.load()
                guard !Task.isCancelled else { return }
                self.settings = loadedSettings
            } catch {
                // Defaults remain available when persistence is unavailable.
            }
        }
    }

    deinit {
        loadTask?.cancel()
        saveTask?.cancel()
    }

    public func setSoundEffectsEnabled(_ isEnabled: Bool) {
        update { $0.soundEffectsEnabled = isEnabled }
    }

    public func setMotionControlEnabled(_ isEnabled: Bool) {
        update { $0.motionControlEnabled = isEnabled }
    }

    public func setTheme(_ theme: AppTheme) {
        update { $0.theme = theme }
    }

    private func update(_ change: (inout AppSettings) -> Void) {
        change(&settings)
        saveTask?.cancel()
        let settingsToSave = settings
        saveTask = Task { [store] in
            try? await store.save(settingsToSave)
        }
    }
}
