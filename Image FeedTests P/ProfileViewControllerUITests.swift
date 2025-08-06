//
//  ProfileViewControllerUITests.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

import XCTest
@testable import Image_Feed

final class ProfileViewControllerUITests: XCTestCase {
    var sut: ProfileViewController!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController
        sut.configure(ProfilePresenterSpy())
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testUpdateProfile_updatesUILabelsCorrectly() {
        sut.updateProfile(name: "Test Name", login: "@testlogin", bio: "Test Bio")
        XCTAssertEqual(sut.nameLabel.text, "Test Name")
        XCTAssertEqual(sut.loginNameLabel.text, "@testlogin")
        XCTAssertEqual(sut.descriptionLabel.text, "Test Bio")
    }

    func testUpdateProfile_withNilBio_setsEmptyDescription() {
        sut.updateProfile(name: "Name", login: "@login", bio: nil)
        XCTAssertEqual(sut.descriptionLabel.text, "")
    }

    func testLogoutButton_callsPresenterLogoutTapped() {
        let presenter = ProfilePresenterSpy()
        sut.configure(presenter)
        sut.loadViewIfNeeded()

        sut.logoutButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(presenter.logoutTappedCalled)
    }
}

// MARK: - Spy

private final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var logoutTappedCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logoutTapped() {
        logoutTappedCalled = true
    }
}
