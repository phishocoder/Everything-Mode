import XCTest

final class GentleResetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testStateShiftFlowCompletes() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["beginResetButton"].waitForExistence(timeout: 2))
        app.buttons["beginResetButton"].tap()

        XCTAssertTrue(app.buttons["state_racing"].waitForExistence(timeout: 2))
        app.buttons["state_racing"].tap()

        let continueButton = app.buttons["continueFromBreathButton"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 12))
        continueButton.tap()

        XCTAssertTrue(app.buttons["choice_park"].waitForExistence(timeout: 2))
        app.buttons["choice_park"].tap()

        XCTAssertTrue(app.buttons["finishResetButton"].isEnabled)
        app.buttons["finishResetButton"].tap()

        XCTAssertTrue(app.staticTexts["Done for now."].waitForExistence(timeout: 2))

        app.buttons["resetAgainButton"].tap()
        XCTAssertTrue(app.staticTexts["Everything feels like too much."].waitForExistence(timeout: 2))
    }
}
