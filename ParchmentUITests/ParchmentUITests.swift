import XCTest

@MainActor
final class ParchmentUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }

    func testSelect() {
        let cell0 = app.collectionViews.cells["View 0"]
        let cell1 = app.collectionViews.cells["View 1"]

        cell1.tap()
        let content1 = app.scrollViews.firstMatch.staticTexts["1"]
        XCTAssertTrue(content1.waitForExistence(timeout: 1))
        XCTAssertTrue(cell1.isSelected)

        cell0.tap()
        let content0 = app.scrollViews.firstMatch.staticTexts["0"]
        XCTAssertTrue(content0.waitForExistence(timeout: 1))
        XCTAssertTrue(cell0.isSelected)
    }

    func testSwipe() {
        app.scrollViews.firstMatch.swipeLeft()
        let content1 = app.scrollViews.firstMatch.staticTexts["1"]
        XCTAssertTrue(content1.waitForExistence(timeout: 1))

        let cell1 = app.collectionViews.cells["View 1"]
        XCTAssertTrue(cell1.isSelected)
    }
}
