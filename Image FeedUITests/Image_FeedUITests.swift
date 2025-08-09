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
        
        sleep(3)

        // 3. Вводим email
        let emailTextField = webView.textFields.element
        XCTAssertTrue(emailTextField.waitForExistence(timeout: 10))
        emailTextField.tap()
        emailTextField.typeText("designlabbrooklyn@gmail.com")

        // 4. Скроллим вниз до пароля
        let start = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let finish = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: finish)

        // 5. Вводим пароль
        let passwordField = webView.secureTextFields.element
        XCTAssertTrue(passwordField.waitForExistence(timeout: 10))
        let passwordCoordinate = passwordField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        passwordCoordinate.tap()
        passwordField.typeText("Enter1234")
        passwordField.typeText("\n")// добавлено \n сразу

        // 6. Проверяем, что появилась лента
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()

        // === Auth if needed ===
        let authButton = app.buttons["Authenticate"]
        if authButton.waitForExistence(timeout: 3) {
            authButton.tap()

            let webView = app.webViews["UnsplashWebView"]
            XCTAssertTrue(webView.waitForExistence(timeout: 10))

            let emailTextField = webView.textFields.element
            XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
            emailTextField.tap()
            emailTextField.typeText("designlabbrooklyn@gmail.com")

            // dismiss keyboard
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()

            let passwordField = webView.secureTextFields.element
            XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
            passwordField.tap()
            passwordField.typeText("Enter1234\n")
        }

        // === Wait for feed ===
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10))
        XCTAssertTrue(table.cells.firstMatch.waitForExistence(timeout: 10))

        // === Force scroll ALL the way to the top ===
        // A few long drags downward is more reliable than swipeDown()
        let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end   = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        for _ in 0..<6 { start.press(forDuration: 0.01, thenDragTo: end) }
        sleep(1)

        // Top cell
        let firstCell = table.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        // If like button area is offscreen, give a tiny nudge
        if !firstCell.isHittable {
            let nudgeStart = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let nudgeEnd   = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            nudgeStart.press(forDuration: 0.01, thenDragTo: nudgeEnd)
        }

        // Like / unlike
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        likeButton.tap()

        // Open first image
        firstCell.tap()

        // Wait image screen
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 5))

        // Zoom in/out
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        // Back
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


// MARK: - UI Test Helpers
private extension XCUIElement {
    
    /// Скроллит элемент в видимую область (сначала вниз, потом вверх)
    func bringIntoView(in scrollView: XCUIElement, maxSwipes: Int = 12) {
        var swipes = 0
        while !isHittable && swipes < maxSwipes {
            scrollView.swipeDown()
            swipes += 1
        }
        if !isHittable {
            swipes = 0
            while !isHittable && swipes < maxSwipes {
                scrollView.swipeUp()
                swipes += 1
            }
        }
    }
    
    /// Безопасный тап: если не hittable — скроллим и пробуем по координате
    func safeTap(in scrollView: XCUIElement? = nil) {
        if let scroll = scrollView, !isHittable {
            bringIntoView(in: scroll)
        }
        if isHittable {
            tap()
        } else {
            let coord = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coord.tap()
        }
    }
    
}
