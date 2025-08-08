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
        app.launchArguments.append("--uitesting")
        app.launch()

        // 1. Кнопка авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()

        // 2. WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        // 3. Вводим email
        let emailTextField = webView.textFields.element
        XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
        emailTextField.tap()
        emailTextField.typeText("designlabbrooklyn@gmail.com")

        // 4. Скроллим вниз (имитация свайпа вверх, чтобы появилось поле пароля)
        let start = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let finish = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: finish)

        // 5. Вводим пароль
        let passwordField = webView.secureTextFields.element
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        let passwordCoordinate = passwordField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        passwordCoordinate.tap()
        passwordField.typeText("753159nnNN123!") // \n = нажатие "Enter"
        passwordField.typeText("\n")

        // 6. Проверяем, что появился список фото
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Авторизация
        let authButton = app.buttons["Authenticate"]
        if authButton.exists {
            authButton.tap()

            let webView = app.webViews["UnsplashWebView"]
            XCTAssertTrue(webView.waitForExistence(timeout: 10))

            let emailTextField = webView.textFields.element
            XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
            emailTextField.tap()
            emailTextField.typeText("demo@demo.com")

            // Тапнуть вне поля email, чтобы скрыть клавиатуру
            let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            coordinate.tap()

            let passwordSecureField = webView.secureTextFields.element
            XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5))
            passwordSecureField.tap()
            passwordSecureField.typeText("password123")
            passwordSecureField.typeText("\n")
        }

        // 2. Таблица
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10))

        // 3. Прокрутка и поиск ячейки
        table.swipeUp()
        table.swipeDown()

        let cell = table.cells["ImagesListCell"].firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.tap() // можно опционально

        // 4. Проверка на наличие кнопки Like
        let likeButton = cell.buttons["likeButton"] // укажи точный identifier, если есть
        XCTAssertTrue(likeButton.exists)
    }



    func testProfile() {
        let app = XCUIApplication()
        app.launch()

        // 1. Подождать загрузку ленты
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10))

        // 2. Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()

        // 3. Проверить отображение имени (по Accessibility Identifier)
        let nameLabel = app.staticTexts["ProfileNameLabel"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))

        // 4. Нажать кнопку выхода
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        // 5. Проверить, что вернулись на экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }

}
