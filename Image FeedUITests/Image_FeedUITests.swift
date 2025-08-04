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
        // Передаём флаг, чтобы приложение знало — идёт UI-тест
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    // MARK: - Авторизация
    func testAuth() throws {
        // Ждём появления кнопки авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка авторизации не найдена")
        authButton.tap()

        // Ждём появления WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")

        // Логин
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        webView.swipeUp()

        // Пароль
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        webView.swipeUp()

        // Кнопка входа
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Кнопка Login не найдена")
        loginButton.tap()

        // Ждём появления ленты
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Лента не загрузилась")
    }

    // MARK: - Лента
    func testFeed() throws {
        // Ждём таблицу
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Лента не найдена")

        // Скроллим
        table.swipeUp()
        sleep(1)

        // Лайк / анлайк
        let firstCell = table.cells.element(boundBy: 0)
        let likeButtonOff = firstCell.buttons["like button off"]
        if likeButtonOff.waitForExistence(timeout: 2) {
            likeButtonOff.tap()
        }
        let likeButtonOn = firstCell.buttons["like button on"]
        if likeButtonOn.waitForExistence(timeout: 2) {
            likeButtonOn.tap()
        }

        // Открываем картинку
        firstCell.tap()

        // Ждём картинку
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Картинка не открылась")

        // Увеличиваем
        image.pinch(withScale: 3, velocity: 1)

        // Уменьшаем
        image.pinch(withScale: 0.5, velocity: -1)

        // Возврат
        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка Back не найдена")
        backButton.tap()
    }

    // MARK: - Профиль
    func testProfile() throws {
        // Ждём TabBar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "TabBar не найден")

        // Переход в профиль
        tabBar.buttons.element(boundBy: 1).tap()

        // Проверяем данные
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists, "Имя не найдено")
        XCTAssertTrue(app.staticTexts["@username"].exists, "Логин не найден")

        // Logout
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Кнопка logout не найдена")
        logoutButton.tap()

        // Подтверждаем выход
        let confirmButton = app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5), "Кнопка подтверждения выхода не найдена")
        confirmButton.tap()

        // Проверяем, что снова экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Экран авторизации не открылся")
    }
}
