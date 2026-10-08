public struct Statistics: Codable, Equatable, Sendable {
    public private(set) var totalFlips: Int
    public private(set) var sixCount: Int
    public private(set) var sevenCount: Int
    public private(set) var sixtySevenCount: Int
    public private(set) var currentStreak: Int
    public private(set) var bestStreak: Int

    public static let empty = Statistics()

    public init(
        totalFlips: Int = 0,
        sixCount: Int = 0,
        sevenCount: Int = 0,
        sixtySevenCount: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0
    ) {
        self.totalFlips = totalFlips
        self.sixCount = sixCount
        self.sevenCount = sevenCount
        self.sixtySevenCount = sixtySevenCount
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
    }

    public mutating func record(_ outcome: Outcome) {
        totalFlips += 1
        currentStreak += 1
        bestStreak = max(bestStreak, currentStreak)

        switch outcome {
        case .six:
            sixCount += 1
        case .seven:
            sevenCount += 1
        case .sixtySeven:
            sixtySevenCount += 1
        }
    }
}
