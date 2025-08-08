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
        emailTextField.typeText("******")

        // 4. Скроллим вниз (имитация свайпа вверх, чтобы появилось поле пароля)
        let start = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let finish = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: finish)

        // 5. Вводим пароль
        let passwordField = webView.secureTextFields.element
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        let passwordCoordinate = passwordField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        passwordCoordinate.tap()
        passwordField.typeText("********") // \n = нажатие "Enter"
        passwordField.typeText("\n")

        // 6. Проверяем, что появился список фото
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()

        // Авторизация (если требуется)
        let authButton = app.buttons["Authenticate"]
        if authButton.waitForExistence(timeout: 3) {
            authButton.tap()

            let webView = app.webViews["UnsplashWebView"]
            XCTAssertTrue(webView.waitForExistence(timeout: 10))

            let emailTextField = webView.textFields.element
            XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
            emailTextField.tap()
            emailTextField.typeText("designlabbrooklyn@gmail.com")

            let dismissKeyboardCoord = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            dismissKeyboardCoord.tap()

            let passwordField = webView.secureTextFields.element
            XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
            passwordField.tap()
            passwordField.typeText("753159nnNN123!") // \n = нажатие "Enter"
            passwordField.typeText("\n")
        }

        // 1. Подождать, пока открывается и загружается экран ленты
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10))

        // 2. Сделать жест «смахивания» вверх по экрану
        table.swipeUp()
        table.swipeDown() // ← для надёжности, чтобы верхние ячейки появились

        // 3. Поставить лайк в ячейке верхней картинки
        let firstCell = table.cells.element(boundBy: 0)
        while !firstCell.isHittable {
            table.swipeDown()
        }

        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))

        likeButton.tap() // 3. лайк
        likeButton.tap() // 4. отмена лайка

        // 5. Нажать на верхнюю ячейку
        firstCell.tap()

        // 6. Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 5))

        // 7. Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)

        // 8. Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)

        // 9. Вернуться на экран ленты
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
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
