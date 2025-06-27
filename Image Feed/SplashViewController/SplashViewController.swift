import UIKit

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLogo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            switchToTabBarController()
        } else {
            showAuthScreen()
        }
    }

    private func setupLogo() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func showAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("❌ Could not instantiate AuthViewController")
        }
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func showLoginErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        self.present(alert, animated: true)
    }


    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show() // ⬅️ Показываем HUD сразу

        oauth2Service.fetchOAuthToken(code) { [weak self] (result: Result<String, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                profileService.fetchProfile(token) { result in
                    switch result {
                    case .success(let profile):
                        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                        DispatchQueue.main.async {
                            UIBlockingProgressHUD.dismiss() // ⬅️ Скрываем HUD
                            self.switchToTabBarController()
                        }
                    case .failure(let error):
                        print("❌ Не удалось загрузить профиль: \(error)")
                        DispatchQueue.main.async {
                            UIBlockingProgressHUD.dismiss() // ⬅️ Обязательно скрыть
                            self.switchToTabBarController() // ⬅️ Переходим даже при ошибке
                        }
                    }
                }

            case .failure(let error):
                print("❌ Ошибка получения токена: \(error)")
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss() // ⬅️ Скрыть в случае ошибки
                    self.showLoginErrorAlert()
                }
            }
        }
    }

}
