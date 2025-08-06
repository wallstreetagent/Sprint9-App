//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Yanye Velikanova on 8/4/25.
//


import XCTest

final class Image_FeedUITests: XCTestCase {

    func testAuth() throws {
        let app = XCUIApplication()
        app.launch()

 
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 5), "Окно приложения не найдено")
    }

    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()


        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 5), "Лента не найдена")
    }

    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()


        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 5), "TabBar не найден")

   
        XCTAssertTrue(app.staticTexts.firstMatch.exists, "Имя не найдено")
        XCTAssertTrue(app.staticTexts.firstMatch.exists, "Логин не найден")
    }
}
