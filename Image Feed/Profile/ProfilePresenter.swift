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
    private let profileService = ProfileService()

    func viewDidLoad() {
        view?.showLoadingState()

        guard let token = OAuth2TokenStorage().token else {
            print("❌ Нет токена для запроса профиля")
            return
        }

        print("👉 fetchOAuthToken завершён, вызываем fetchProfile с токеном: \(token)")
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.view?.updateProfile(
                        name: profile.name,
                        login: profile.loginName,
                        bio: profile.bio
                    )

                    if let avatarURL = ProfileImageService.shared.avatarURL,
                       let url = URL(string: avatarURL) {
                        self?.view?.updateAvatar(url: url)
                    }

                    self?.view?.hideLoadingState()

                case .failure(let error):
                    print("❌ Ошибка загрузки профиля: \(error)")
                }
            }
        }
    }

    func logoutTapped() {
        OAuth2TokenStorage.shared.token = nil
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
