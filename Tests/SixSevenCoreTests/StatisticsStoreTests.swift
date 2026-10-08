import Foundation
import XCTest
@testable import SixSevenCore

final class StatisticsStoreTests: XCTestCase {
    func testUserDefaultsStoreRoundTrip() async throws {
        let suiteName = "SixSevenTests.\(UUID().uuidString)"
        let store = UserDefaultsStatisticsStore(suiteName: suiteName)
        var expected = Statistics.empty
        expected.record(.sixtySeven)
        expected.record(.six)

        try await store.save(expected)
        let actual = try await store.load()

        XCTAssertEqual(actual, expected)
        try XCTUnwrap(UserDefaults(suiteName: suiteName)).removePersistentDomain(forName: suiteName)
    }

    func testEmptyStoreReturnsEmptyStatistics() async throws {
        let suiteName = "SixSevenTests.\(UUID().uuidString)"
        let store = UserDefaultsStatisticsStore(suiteName: suiteName)

        let actual = try await store.load()
        XCTAssertEqual(actual, .empty)
        try XCTUnwrap(UserDefaults(suiteName: suiteName)).removePersistentDomain(forName: suiteName)
    }
}

final class SharePayloadTests: XCTestCase {
    func testShareTextIncludesQuestionAndOutcome() {
        let result = FlipResult(outcome: .sixtySeven, question: "Should I go?")

        XCTAssertEqual(
            SharePayload.text(for: result),
            "I asked SixSeven it!: \"Should I go?\" → 67. Can't decide? Sixseven it."
        )
    }

    func testShareTextWorksWithoutQuestion() {
        let result = FlipResult(outcome: .six)

        XCTAssertEqual(
            SharePayload.text(for: result),
            "I asked SixSeven it!: 6. Can't decide? Sixseven it."
        )
    }
}
