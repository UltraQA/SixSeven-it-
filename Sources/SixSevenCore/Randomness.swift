public protocol RandomNumberGenerating: Sendable {
    mutating func nextInt(in range: ClosedRange<Int>) -> Int
}

public protocol FlipOutcomeProviding: Sendable {
    mutating func makeOutcome() -> Outcome
}

public struct SystemRandomNumberGeneratorAdapter: RandomNumberGenerating {
    private var generator = SystemRandomNumberGenerator()

    public init() {}

    public mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range, using: &generator)
    }
}

public struct WeightedOutcomeProvider<Generator: RandomNumberGenerating>: FlipOutcomeProviding {
    private var generator: Generator
    private let rules: GameRules

    public init(generator: Generator, rules: GameRules = GameRules()) {
        self.generator = generator
        self.rules = rules
    }

    public mutating func makeOutcome() -> Outcome {
        rules.outcome(for: generator.nextInt(in: GameRules.randomRange))
    }
}
