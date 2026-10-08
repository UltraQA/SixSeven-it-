import Foundation
import Combine
import SixSevenCore

@MainActor
public final class HomeViewModel<Provider: FlipOutcomeProviding>: ObservableObject {
    @Published public private(set) var state: GameState

    private var provider: Provider
    private let animationDuration: Duration
    private var completionTask: Task<Void, Never>?

    public init(
        provider: Provider,
        state: GameState = GameState(),
        animationDuration: Duration = .milliseconds(650)
    ) {
        self.provider = provider
        self.state = state
        self.animationDuration = animationDuration
    }

    deinit {
        completionTask?.cancel()
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

    public func flip() {
        guard state.beginFlip() else { return }

        let outcome = provider.makeOutcome()
        completionTask?.cancel()
        completionTask = Task { [weak self] in
            do {
                try await Task.sleep(for: self?.animationDuration ?? .zero)
            } catch {
                return
            }

            guard !Task.isCancelled, let self else { return }
            _ = self.state.finishFlip(with: outcome)
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
