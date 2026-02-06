import XCTest

final class GentleResetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testStateShiftFlowCompletes() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_FAST")
        app.launch()

        XCTAssertTrue(app.buttons["beginResetButton"].waitForExistence(timeout: 2))
        app.buttons["beginResetButton"].tap()

        XCTAssertTrue(app.buttons["state_racing"].waitForExistence(timeout: 2))
        app.buttons["state_racing"].tap()

        let inhaleLabel = app.staticTexts["Breathe in"]
        let exhaleLabel = app.staticTexts["Breathe out"]
        XCTAssertTrue(
            inhaleLabel.waitForExistence(timeout: 2) || exhaleLabel.waitForExistence(timeout: 2)
        )

        XCTAssertTrue(app.staticTexts["Reset complete."].waitForExistence(timeout: 12))

        app.buttons["resetAgainButton"].tap()
        XCTAssertTrue(app.staticTexts["Everything feels like too much."].waitForExistence(timeout: 2))
    }
}
