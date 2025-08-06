//
//  Profiletest.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//


@testable import Image_Feed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsPresenterViewDidLoad() {
        let presenterSpy = TestProfilePresenterSpy()
        let sut = ProfileViewController()
        sut.configure(presenterSpy)
        _ = sut.view
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testConfigureSetsPresenterAndView() {
        let presenterSpy = TestProfilePresenterSpy()
        let sut = ProfileViewController()
        sut.configure(presenterSpy)
        XCTAssertTrue(presenterSpy.view === sut)
    }

    func testPresenterSetsProfileData_onViewDidLoad() {
        let viewSpy = TestProfileViewSpy()
        let presenter = TestProfilePresenterWithFakeData()
        presenter.view = viewSpy
        presenter.viewDidLoad()
        XCTAssertTrue(viewSpy.showProfileCalled)
        XCTAssertEqual(viewSpy.receivedProfile?.name, "Имя ")
        XCTAssertEqual(viewSpy.receivedProfile?.loginName, "@login")
        XCTAssertEqual(viewSpy.receivedProfile?.bio, "Описание профиля")
    }
}

// MARK: 

private final class TestProfileViewSpy: ProfileViewControllerProtocol {
    var showProfileCalled = false
    var receivedProfile: (name: String, loginName: String, bio: String?)?

    func updateProfile(name: String, login: String, bio: String?) {
        showProfileCalled = true
        receivedProfile = (name, login, bio)
    }
    func updateAvatar(url: URL) {}
    func showLoadingState() {}
    func hideLoadingState() {}
}

private final class TestProfilePresenterWithFakeData: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    func viewDidLoad() {
        view?.updateProfile(name: "Имя ", login: "@login", bio: "Описание профиля")
    }
    func logoutTapped() {}
}

private final class TestProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func logoutTapped() {}
}
