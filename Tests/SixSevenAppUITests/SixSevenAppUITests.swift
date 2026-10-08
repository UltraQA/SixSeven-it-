import XCTest

@MainActor
final class SixSevenAppUITests: XCTestCase {
    func testFlipShowsResultAndShareAction() {
        let app = XCUIApplication()
        app.launch()

        let flipButton = app.buttons["sixseven.flipButton"]
        XCTAssertTrue(flipButton.waitForExistence(timeout: 3))
        flipButton.tap()

        let shareButton = app.buttons["sixseven.shareButton"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 3))
    }
}
