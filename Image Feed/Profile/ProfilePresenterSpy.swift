//
//  ProfilePresenterSpy.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

@testable import Image_Feed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
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
