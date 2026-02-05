import XCTest

final class GentleResetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHappyPathCompletesReset() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["startResetButton"].waitForExistence(timeout: 2))
        app.buttons["startResetButton"].tap()

        XCTAssertTrue(app.buttons["continueFromDumpButton"].waitForExistence(timeout: 2))
        let dumpEditor = app.textViews["brainDumpEditor"]
        XCTAssertTrue(dumpEditor.waitForExistence(timeout: 2))
        dumpEditor.tap()
        dumpEditor.typeText("Work messages, laundry, and an overdue call.")
        app.buttons["continueFromDumpButton"].tap()

        let practical = app.buttons["category_practical"]
        XCTAssertTrue(practical.waitForExistence(timeout: 2))
        practical.tap()
        XCTAssertTrue(app.buttons["continueFromCategoriesButton"].isEnabled)
        app.buttons["continueFromCategoriesButton"].tap()

        let actionField = app.textFields["actionTextField"]
        XCTAssertTrue(actionField.waitForExistence(timeout: 2))
        actionField.tap()
        actionField.typeText("Reply with one sentence")
        app.buttons["continueFromActionButton"].tap()

        let parkChoice = app.buttons["closing_parkIt"]
        XCTAssertTrue(parkChoice.waitForExistence(timeout: 2))
        parkChoice.tap()

        XCTAssertTrue(app.buttons["finishResetButton"].isEnabled)
        app.buttons["finishResetButton"].tap()

        XCTAssertTrue(app.staticTexts["You can stop here."].waitForExistence(timeout: 2))
        app.buttons["resetAgainButton"].tap()

        XCTAssertTrue(app.staticTexts["Everything feels like too much right now."].waitForExistence(timeout: 2))
    }
}
