import XCTest
@testable import SixSevenCore

final class GameRulesTests: XCTestCase {
    func testDefaultBoundariesMapToExpectedOutcomes() {
        let rules = GameRules()

        XCTAssertEqual(rules.outcome(for: 0), .six)
        XCTAssertEqual(rules.outcome(for: 4_749), .six)
        XCTAssertEqual(rules.outcome(for: 4_750), .seven)
        XCTAssertEqual(rules.outcome(for: 9_499), .seven)
        XCTAssertEqual(rules.outcome(for: 9_500), .sixtySeven)
        XCTAssertEqual(rules.outcome(for: 9_999), .sixtySeven)
    }

    func testDefaultProbabilitiesUseTenThousandIntegerBuckets() {
        let rules = GameRules()
        var counts: [Outcome: Int] = [:]

        for value in GameRules.randomRange {
            counts[rules.outcome(for: value), default: 0] += 1
        }

        XCTAssertEqual(counts[.six], 4_750)
        XCTAssertEqual(counts[.seven], 4_750)
        XCTAssertEqual(counts[.sixtySeven], 500)
        XCTAssertEqual(counts.values.reduce(0, +), 10_000)
    }
}
