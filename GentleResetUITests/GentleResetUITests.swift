import XCTest

final class GentleResetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCoreLoopCanExitWithoutTranslation() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_FAST")
        app.launch()

        XCTAssertTrue(app.buttons["beginResetButton"].waitForExistence(timeout: 2))
        app.buttons["beginResetButton"].tap()

        let inhaleLabel = app.staticTexts["Breathe in"]
        let exhaleLabel = app.staticTexts["Breathe out"]
        XCTAssertTrue(
            inhaleLabel.waitForExistence(timeout: 2) || exhaleLabel.waitForExistence(timeout: 2)
        )

        XCTAssertTrue(app.staticTexts["Want me to help sort what's weighing on you?"].waitForExistence(timeout: 12))
        app.buttons["skipTranslationButton"].tap()

        XCTAssertTrue(app.staticTexts["Done for now."].waitForExistence(timeout: 2))
        app.buttons["startOverButton"].tap()
        XCTAssertTrue(app.staticTexts["Everything piling up?"].waitForExistence(timeout: 2))
    }
}
