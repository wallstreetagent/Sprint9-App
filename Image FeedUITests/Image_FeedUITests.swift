//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Yanye Velikanova on 8/4/25.
//


import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("--uitesting") 
        app.launch()
    }

    // MARK: - Авторизация (теперь без логина/пароля)
    func testAuth() throws {

        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Лента не загрузилась")
    }

    // MARK: - Лента
    func testFeed() throws {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Лента не найдена")

        let firstCell = table.cells.element(boundBy: 0)
        firstCell.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Картинка не открылась")

        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка Back не найдена")
        backButton.tap()
    }

    // MARK: - Профиль
    func testProfile() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "TabBar не найден")

        tabBar.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts["Name Lastname"].exists, "Имя не найдено")
        XCTAssertTrue(app.staticTexts["@username"].exists, "Логин не найден")
    }
}
