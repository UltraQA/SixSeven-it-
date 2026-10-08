import XCTest
@testable import SixSevenCore

final class StatisticsTests: XCTestCase {
    func testRecordingOutcomesUpdatesCountsAndStreak() {
        var statistics = Statistics.empty

        statistics.record(.six)
        statistics.record(.seven)
        statistics.record(.sixtySeven)

        XCTAssertEqual(statistics.totalFlips, 3)
        XCTAssertEqual(statistics.sixCount, 1)
        XCTAssertEqual(statistics.sevenCount, 1)
        XCTAssertEqual(statistics.sixtySevenCount, 1)
        XCTAssertEqual(statistics.currentStreak, 3)
        XCTAssertEqual(statistics.bestStreak, 3)
        XCTAssertEqual(statistics.currentSixtySevenStreak, 1)
        XCTAssertEqual(statistics.bestSixtySevenStreak, 1)
    }

    func testRareStreakResetsAfterCommonOutcome() {
        var statistics = Statistics.empty

        statistics.record(.sixtySeven)
        statistics.record(.sixtySeven)
        statistics.record(.six)

        XCTAssertEqual(statistics.currentSixtySevenStreak, 0)
        XCTAssertEqual(statistics.bestSixtySevenStreak, 2)
    }
}
