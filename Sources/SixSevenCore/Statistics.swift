public struct Statistics: Codable, Equatable, Sendable {
    public private(set) var totalFlips: Int
    public private(set) var sixCount: Int
    public private(set) var sevenCount: Int
    public private(set) var sixtySevenCount: Int
    public private(set) var currentStreak: Int
    public private(set) var bestStreak: Int
    public private(set) var currentSixtySevenStreak: Int
    public private(set) var bestSixtySevenStreak: Int
    public private(set) var lastOutcome: Outcome?

    public static let empty = Statistics()

    public init(
        totalFlips: Int = 0,
        sixCount: Int = 0,
        sevenCount: Int = 0,
        sixtySevenCount: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        currentSixtySevenStreak: Int = 0,
        bestSixtySevenStreak: Int = 0,
        lastOutcome: Outcome? = nil
    ) {
        self.totalFlips = totalFlips
        self.sixCount = sixCount
        self.sevenCount = sevenCount
        self.sixtySevenCount = sixtySevenCount
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.currentSixtySevenStreak = currentSixtySevenStreak
        self.bestSixtySevenStreak = bestSixtySevenStreak
        self.lastOutcome = lastOutcome
    }

    private enum CodingKeys: String, CodingKey {
        case totalFlips, sixCount, sevenCount, sixtySevenCount
        case currentStreak, bestStreak
        case currentSixtySevenStreak, bestSixtySevenStreak
        case lastOutcome
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            totalFlips: try container.decode(Int.self, forKey: .totalFlips),
            sixCount: try container.decode(Int.self, forKey: .sixCount),
            sevenCount: try container.decode(Int.self, forKey: .sevenCount),
            sixtySevenCount: try container.decode(Int.self, forKey: .sixtySevenCount),
            currentStreak: try container.decode(Int.self, forKey: .currentStreak),
            bestStreak: try container.decode(Int.self, forKey: .bestStreak),
            currentSixtySevenStreak: try container.decodeIfPresent(Int.self, forKey: .currentSixtySevenStreak) ?? 0,
            bestSixtySevenStreak: try container.decodeIfPresent(Int.self, forKey: .bestSixtySevenStreak) ?? 0,
            lastOutcome: try container.decodeIfPresent(Outcome.self, forKey: .lastOutcome)
        )
    }

    public mutating func record(_ outcome: Outcome) {
        totalFlips += 1
        currentStreak = lastOutcome == outcome ? currentStreak + 1 : 1
        bestStreak = max(bestStreak, currentStreak)
        lastOutcome = outcome

        switch outcome {
        case .six:
            sixCount += 1
            currentSixtySevenStreak = 0
        case .seven:
            sevenCount += 1
            currentSixtySevenStreak = 0
        case .sixtySeven:
            sixtySevenCount += 1
            currentSixtySevenStreak += 1
            bestSixtySevenStreak = max(bestSixtySevenStreak, currentSixtySevenStreak)
        }
    }
}
