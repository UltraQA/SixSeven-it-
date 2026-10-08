import XCTest

@MainActor
final class SixSevenAppUITests: XCTestCase {
    func testFlipShowsResultAndShareAction() {
        let app = XCUIApplication()
        app.launch()

        let coin = app.otherElements["sixseven.coin"]
        XCTAssertTrue(coin.waitForExistence(timeout: 3))
        coin.swipeUp()

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

        let coin = app.otherElements["sixseven.coin"]
        XCTAssertTrue(coin.waitForExistence(timeout: 3))
        coin.swipeUp()

        XCTAssertTrue(app.buttons["sixseven.shareButton"].waitForExistence(timeout: 3))
        XCTAssertEqual(questionInput.value as? String, "Drop your dilemma here…")
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
    }
}
