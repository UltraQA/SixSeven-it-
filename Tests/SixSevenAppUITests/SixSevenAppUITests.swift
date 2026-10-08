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
        app.keyboards.buttons["Done"].tap()

        let coin = app.otherElements["sixseven.coin"]
        XCTAssertTrue(coin.waitForExistence(timeout: 3))
        app.swipeUp()

        XCTAssertTrue(app.buttons["sixseven.shareButton"].waitForExistence(timeout: 3))
        XCTAssertEqual(questionInput.value as? String, "Drop your dilemma here…")
    }

    func testSwipeInAreaBelowShareStartsNextFlip() {
        let app = XCUIApplication()
        app.launch()

        let coin = app.otherElements["sixseven.coin"]
        XCTAssertTrue(coin.waitForExistence(timeout: 3))
        coin.swipeUp()
        XCTAssertTrue(app.buttons["sixseven.shareButton"].waitForExistence(timeout: 3))

        let cooldownExpectation = expectation(description: "Wait for result cooldown")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            cooldownExpectation.fulfill()
        }
        wait(for: [cooldownExpectation], timeout: 2)

        let swipeSurface = app.otherElements["sixseven.swipeSurface"]
        XCTAssertTrue(swipeSurface.waitForExistence(timeout: 3))
        let initialCoinValue = coin.value as? String
        swipeSurface.swipeUp()

        let nextResultPredicate = NSPredicate(format: "value != %@", initialCoinValue ?? "")
        let nextResultExpectation = expectation(for: nextResultPredicate, evaluatedWith: coin)
        wait(for: [nextResultExpectation], timeout: 3)
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
