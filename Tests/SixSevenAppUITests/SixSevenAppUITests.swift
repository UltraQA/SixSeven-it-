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

    func testHomeIsUsableWithDarkModeLargeTextAndReduceMotion() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleInterfaceStyle", "Dark",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
            "-UIAccessibilityReduceMotionEnabled", "YES"
        ]
        app.launch()

        XCTAssertTrue(app.otherElements["sixseven.coin"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["sixseven.flipButton"].exists)
    }
}
