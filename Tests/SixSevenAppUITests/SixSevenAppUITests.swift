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

    func testQuestionClearsAfterCompletedFlip() {
        let app = XCUIApplication()
        app.launch()

        let questionInput = app.textFields["sixseven.questionInput"]
        XCTAssertTrue(questionInput.waitForExistence(timeout: 3))
        questionInput.tap()
        questionInput.typeText("Should I go for it?")

        app.buttons["sixseven.flipButton"].tap()

        XCTAssertTrue(app.buttons["sixseven.shareButton"].waitForExistence(timeout: 3))
        XCTAssertEqual(questionInput.value as? String, "What are you deciding?")
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
