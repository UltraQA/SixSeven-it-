import Foundation

public enum GamePhase: Equatable, Sendable {
    case idle
    case flipping
    case result(FlipResult)
}

public struct GameState: Equatable, Sendable {
    public private(set) var phase: GamePhase
    public var question: String
    public private(set) var statistics: Statistics

    public init(
        phase: GamePhase = .idle,
        question: String = "",
        statistics: Statistics = .empty
    ) {
        self.phase = phase
        self.question = question
        self.statistics = statistics
    }

    public mutating func beginFlip() -> Bool {
        guard phase != .flipping else { return false }
        phase = .flipping
        return true
    }

    public mutating func finishFlip(with outcome: Outcome, date: Date = Date()) -> Bool {
        guard phase == .flipping else { return false }

        let result = FlipResult(outcome: outcome, question: question, date: date)
        statistics.record(outcome)
        phase = .result(result)
        return true
    }

    public mutating func cancelFlip() -> Bool {
        guard phase == .flipping else { return false }
        phase = .idle
        return true
    }

    public mutating func reset() {
        guard case .result = phase else { return }
        phase = .idle
    }
}
