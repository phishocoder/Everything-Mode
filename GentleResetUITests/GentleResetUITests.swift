import XCTest

final class GentleResetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHappyPathCompletesReset() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["startButton"].waitForExistence(timeout: 2))
        app.buttons["startButton"].tap()

        XCTAssertTrue(app.buttons["continueButton"].waitForExistence(timeout: 2))
        app.buttons["continueButton"].tap()

        let actionField = app.textFields["actionTextField"]
        XCTAssertTrue(actionField.waitForExistence(timeout: 2))
        actionField.tap()
        actionField.typeText("Reply with one sentence")

        XCTAssertTrue(app.buttons["pickThisButton"].isEnabled)
        app.buttons["pickThisButton"].tap()

        let scheduleButton = app.buttons["modeScheduleButton"]
        XCTAssertTrue(scheduleButton.waitForExistence(timeout: 2))
        scheduleButton.tap()

        XCTAssertTrue(app.buttons["finishResetButton"].isEnabled)
        app.buttons["finishResetButton"].tap()

        XCTAssertTrue(app.staticTexts["You did enough for now."].waitForExistence(timeout: 2))

        app.buttons["doneButton"].tap()
        XCTAssertTrue(app.staticTexts["If everything feels like too much, you are not broken."].waitForExistence(timeout: 2))
    }
}
