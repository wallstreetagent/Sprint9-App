//
//  TabBarController.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/7/25.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let profileVC = viewControllers?.last as? ProfileViewController {
            let presenter = ProfilePresenter()
            profileVC.configure(presenter)
        }

        if let imagesListVC = viewControllers?.first as? ImagesListViewController {
            let presenter = ImagesListPresenter()
            imagesListVC.configure(presenter)
        }
    }
}
