import Foundation
import Combine
import SixSevenCore

@MainActor
public final class HomeViewModel<Provider: FlipOutcomeProviding>: ObservableObject {
    @Published public private(set) var state: GameState
    @Published public private(set) var settings: AppSettings = .defaults
    @Published public private(set) var isResultCoolingDown = false

    private var provider: Provider
    private let statisticsStore: any StatisticsStore
    private let settingsStore: any SettingsStore
    private let feedback: any FlipFeedbackClient
    private let animationDuration: Duration
    private let resultCooldownDuration: Duration
    private var completionTask: Task<Void, Never>?
    private var resultCooldownTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    public init(
        provider: Provider,
        state: GameState = GameState(),
        statisticsStore: any StatisticsStore = UserDefaultsStatisticsStore(),
        settingsStore: any SettingsStore = UserDefaultsSettingsStore(),
        feedback: any FlipFeedbackClient = NoOpFlipFeedbackClient(),
        animationDuration: Duration = SixSevenTiming.flipAnimation,
        resultCooldownDuration: Duration = SixSevenTiming.resultCooldown
    ) {
        self.provider = provider
        self.state = state
        self.statisticsStore = statisticsStore
        self.settingsStore = settingsStore
        self.feedback = feedback
        self.animationDuration = animationDuration
        self.resultCooldownDuration = resultCooldownDuration

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                async let statistics = statisticsStore.load()
                async let loadedSettings = settingsStore.load()
                guard !Task.isCancelled else { return }
                self.state = GameState(
                    phase: self.state.phase,
                    question: self.state.question,
                    statistics: try await statistics
                )
                self.settings = try await loadedSettings
            } catch {
                // Persistence is optional; a fresh in-memory state remains usable.
            }
        }
    }

    deinit {
        completionTask?.cancel()
        resultCooldownTask?.cancel()
        loadTask?.cancel()
    }

    public var question: String {
        get { state.question }
        set { state.question = newValue }
    }

    public var isFlipping: Bool {
        state.phase == .flipping
    }

    public var isFlipInteractionLocked: Bool {
        isFlipping || isResultCoolingDown
    }

    public var currentOutcome: Outcome? {
        guard case let .result(result) = state.phase else { return nil }
        return result.outcome
    }

    public var statistics: Statistics {
        state.statistics
    }

    public func flip() {
        guard !isResultCoolingDown else { return }
        guard state.beginFlip() else { return }

        let outcome = provider.makeOutcome()
        completionTask?.cancel()
        completionTask = Task { [weak self] in
            let soundEffectsEnabled = self?.settings.soundEffectsEnabled ?? false
            await self?.feedback.playLaunch(soundEffectsEnabled: soundEffectsEnabled)
            do {
                try await Task.sleep(for: self?.animationDuration ?? .zero)
            } catch {
                if Task.isCancelled {
                    self?.cancelPendingFlip()
                }
                return
            }

            guard !Task.isCancelled, let self else { return }
            guard self.state.finishFlip(with: outcome) else { return }
            self.state.question = ""
            self.beginResultCooldown()
            await self.feedback.playResult(
                for: outcome,
                soundEffectsEnabled: self.settings.soundEffectsEnabled
            )

            do {
                try await self.statisticsStore.save(self.state.statistics)
            } catch {
                // A storage failure must not invalidate a completed flip.
            }
        }
    }

    public func refreshSettings() async {
        loadTask?.cancel()
        loadTask = nil
        guard let loadedSettings = try? await settingsStore.load() else { return }
        settings = loadedSettings
    }

    public func apply(settings: AppSettings) {
        self.settings = settings
    }

    public func handleShake() {
        guard settings.motionControlEnabled else { return }
        flip()
    }

    public func handleSwipeUp() {
        guard !isResultCoolingDown else { return }
        if currentOutcome == nil {
            flip()
        } else {
            flipAgain()
        }
    }

    public func flipAgain() {
        guard !isResultCoolingDown else { return }
        guard case .result = state.phase else { return }
        state.reset()
        flip()
    }

    public func cancelPendingFlip() {
        completionTask?.cancel()
        completionTask = nil
        resultCooldownTask?.cancel()
        resultCooldownTask = nil
        isResultCoolingDown = false
        _ = state.cancelFlip()
    }

    private func beginResultCooldown() {
        resultCooldownTask?.cancel()

        guard resultCooldownDuration != .zero else {
            resultCooldownTask = nil
            isResultCoolingDown = false
            return
        }

        isResultCoolingDown = true
        resultCooldownTask = Task { [weak self, resultCooldownDuration] in
            do {
                try await Task.sleep(for: resultCooldownDuration)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            self?.isResultCoolingDown = false
            self?.resultCooldownTask = nil
        }
    }
}
