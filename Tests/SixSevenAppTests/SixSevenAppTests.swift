import XCTest
@testable import SixSevenCore

final class SixSevenAppTests: XCTestCase {
    func testNativeTargetCanUseCoreModule() {
        XCTAssertEqual(GameRules().outcome(for: 9_999), .sixtySeven)
    }
}
