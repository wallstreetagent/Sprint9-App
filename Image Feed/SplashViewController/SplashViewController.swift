
// File name: SplashViewController

import UIKit

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        print("📱 SplashViewController instance:", ObjectIdentifier(self))
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLogo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
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
        print("✅ Делегат установлен в AuthViewController")
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

    private func fetchProfile(_ token: String) {
        print("👤 Получаем профиль с токеном: \(token)")
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let profile):
                print("✅ Профиль получен: \(profile)")
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                }

            case .failure(let error):
                print("❌ Не удалось загрузить профиль: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    self.showLoginErrorAlert()
                }
            }
        }
    }

    private func showLoginErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        self.present(alert, animated: true)
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
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode token: String) {
        print("🌟 SplashViewController получил токен от AuthViewController")
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.oauth2TokenStorage.token = token
            self.fetchProfile(token)
        }
    }
}
