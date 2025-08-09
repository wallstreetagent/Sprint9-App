//
//  ProfilePresenter.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/4/25.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logoutTapped()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared

    func viewDidLoad() {
        view?.showLoadingState()

        guard let profile = profileService.profile else {
            view?.hideLoadingState()
            return
        }

        view?.updateProfile(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio
        )

        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            view?.updateAvatar(url: url)
        }

        view?.hideLoadingState()
    }

    func logoutTapped() {
        tokenStorage.token = nil
        ProfileLogoutService.shared.logout()

        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            return
        }

        if let window = UIApplication.shared.windows.first {
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
        }
    }
}
