//
//  ProfileLogoutService.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 7/21/25.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() { }

    func logout() {
        OAuth2TokenStorage.shared.removeToken()

        cleanCookies()

        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()

        switchToSplashViewController()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController")

        window.rootViewController = splashVC
    }
}
