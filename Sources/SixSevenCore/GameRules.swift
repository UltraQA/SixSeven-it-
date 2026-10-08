public struct GameRules: Equatable, Sendable {
    public static let randomRange = 0...9_999

    public let sixThreshold: Int
    public let sevenThreshold: Int

    public init(sixThreshold: Int = 4_750, sevenThreshold: Int = 9_500) {
        precondition(
            Self.randomRange.contains(sixThreshold - 1),
            "sixThreshold must be between 1 and 10,000"
        )
        precondition(
            sevenThreshold > sixThreshold && sevenThreshold <= Self.randomRange.upperBound + 1,
            "sevenThreshold must be greater than sixThreshold and at most 10,000"
        )

        self.sixThreshold = sixThreshold
        self.sevenThreshold = sevenThreshold
    }

    public func outcome(for randomValue: Int) -> Outcome {
        precondition(Self.randomRange.contains(randomValue), "Random value must be in 0...9,999")

        return switch randomValue {
        case ..<sixThreshold:
            Outcome.six
        case ..<sevenThreshold:
            Outcome.seven
        default:
            Outcome.sixtySeven
        }
    }
}
