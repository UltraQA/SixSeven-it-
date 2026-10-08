import Foundation
import XCTest
@testable import SixSevenCore

final class GameStateTests: XCTestCase {
    func testConcurrentFlipIsRejected() {
        var state = GameState()

        XCTAssertTrue(state.beginFlip())
        XCTAssertFalse(state.beginFlip())
        XCTAssertEqual(state.phase, .flipping)
    }

    func testFinishFlipCreatesResultAndRecordsStatistics() {
        var state = GameState(question: "  Should I go?  ")
        let date = Date(timeIntervalSince1970: 123)

        XCTAssertTrue(state.beginFlip())
        XCTAssertTrue(state.finishFlip(with: .sixtySeven, date: date))

        XCTAssertEqual(
            state.phase,
            .result(FlipResult(outcome: .sixtySeven, question: "Should I go?", date: date))
        )
        XCTAssertEqual(state.statistics.sixtySevenCount, 1)
        XCTAssertFalse(state.finishFlip(with: .six))
    }

    func testResetOnlyLeavesResultPhase() {
        var state = GameState()

        state.reset()
        XCTAssertEqual(state.phase, .idle)

        XCTAssertTrue(state.beginFlip())
        state.reset()
        XCTAssertEqual(state.phase, .flipping)

        XCTAssertTrue(state.finishFlip(with: .seven))
        state.reset()
        XCTAssertEqual(state.phase, .idle)
    }

    func testCancelFlipReturnsToIdleWithoutRecordingResult() {
        var state = GameState()

        XCTAssertTrue(state.beginFlip())
        XCTAssertTrue(state.cancelFlip())
        XCTAssertEqual(state.phase, .idle)
        XCTAssertEqual(state.statistics.totalFlips, 0)
        XCTAssertFalse(state.cancelFlip())
    }
}
