import Foundation
import Combine
import SixSevenCore

@MainActor
public final class HomeViewModel<Provider: FlipOutcomeProviding>: ObservableObject {
    @Published public private(set) var state: GameState

    private var provider: Provider
    private let statisticsStore: any StatisticsStore
    private let feedback: any FlipFeedbackClient
    private let animationDuration: Duration
    private var completionTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    public init(
        provider: Provider,
        state: GameState = GameState(),
        statisticsStore: any StatisticsStore = UserDefaultsStatisticsStore(),
        feedback: any FlipFeedbackClient = NoOpFlipFeedbackClient(),
        animationDuration: Duration = .milliseconds(650)
    ) {
        self.provider = provider
        self.state = state
        self.statisticsStore = statisticsStore
        self.feedback = feedback
        self.animationDuration = animationDuration

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let statistics = try await statisticsStore.load()
                guard !Task.isCancelled else { return }
                self.state = GameState(
                    phase: self.state.phase,
                    question: self.state.question,
                    statistics: statistics
                )
            } catch {
                // Persistence is optional; a fresh in-memory state remains usable.
            }
        }
    }

    deinit {
        completionTask?.cancel()
        loadTask?.cancel()
    }

    public var question: String {
        get { state.question }
        set { state.question = newValue }
    }

    public var isFlipping: Bool {
        state.phase == .flipping
    }

    public var currentOutcome: Outcome? {
        guard case let .result(result) = state.phase else { return nil }
        return result.outcome
    }

    public var statistics: Statistics {
        state.statistics
    }

    public func flip() {
        guard state.beginFlip() else { return }

        let outcome = provider.makeOutcome()
        completionTask?.cancel()
        completionTask = Task { [weak self] in
            await self?.feedback.playLaunch()
            do {
                try await Task.sleep(for: self?.animationDuration ?? .zero)
            } catch {
                return
            }

            guard !Task.isCancelled, let self else { return }
            guard self.state.finishFlip(with: outcome) else { return }
            await self.feedback.playResult(for: outcome)

            do {
                try await self.statisticsStore.save(self.state.statistics)
            } catch {
                // A storage failure must not invalidate a completed flip.
            }
        }
    }

    public func flipAgain() {
        guard case .result = state.phase else { return }
        state.reset()
        flip()
    }

    public func cancelPendingFlip() {
        completionTask?.cancel()
        completionTask = nil
    }
}
