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
    }
}
