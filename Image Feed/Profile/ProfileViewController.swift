import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    private var animationLayers = Set<CALayer>()

    @IBAction private func didTapLogout(_ sender: UIButton) {
        showLogoutAlert()
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: Strings.logoutTitle,
            message: Strings.logoutMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: Strings.cancelButton, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Strings.confirmButton, style: .destructive) { _ in
            self.logout()
        })

        present(alert, animated: true)
    }

    private enum Strings {
        static let logoutTitle = "Пока-пока!"
        static let logoutMessage = "Are you sure you want to log out?"
        static let cancelButton = "Нет"
        static let confirmButton = "Да"
    }

    private func logout() {
        OAuth2TokenStorage.shared.token = nil
        ProfileLogoutService.shared.logout()

        if let window = UIApplication.shared.windows.first {
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
        }
    }

 
    private let profileService = ProfileService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            addObserver()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            addObserver()
        }

        deinit {
            removeObserver()
        }

        // MARK: - Жизненный цикл

        override func viewDidLoad() {
            super.viewDidLoad()
            showLoadingGradient()
            
            guard let token = OAuth2TokenStorage().token else {
                print("❌ Нет токена для запроса профиля")
                return
            }

            print("👉 fetchOAuthToken завершён, вызываем fetchProfile с токеном: \(token)")
            profileService.fetchProfile(token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.nameLabel.text = profile.name
                        self?.loginNameLabel.text = profile.loginName
                        self?.descriptionLabel.text = profile.bio
                    case .failure(let error):
                        print("❌ Ошибка загрузки профиля: \(error)")
                    }
                }
            }

            if let avatarURL = ProfileImageService.shared.avatarURL,
               let url = URL(string: avatarURL) {
                avatarImageView.kf.setImage(with: url)
            }
        }

        // MARK: - Действия

        @IBAction private func didTapLogoutButton() {
            // TODO: Обработка выхода
        }

        // MARK: - Observer

        private func addObserver() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateAvatar(notification:)),
                name: ProfileImageService.didChangeNotification,
                object: nil
            )
        }

        private func removeObserver() {
            NotificationCenter.default.removeObserver(
                self,
                name: ProfileImageService.didChangeNotification,
                object: nil
            )
        }

    @objc private func updateAvatar(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.removeLoadingGradients()
            guard
                self.isViewLoaded,
                let userInfo = notification.userInfo,
                let profileImageURL = userInfo["URL"] as? String,
                let url = URL(string: profileImageURL)
            else { return }

            self.avatarImageView.kf.setImage(with: url)
        }
    }


    private func makeAnimatedGradient(for view: UIView, cornerRadius: CGFloat = 0) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "locationsChange")

        animationLayers.insert(gradient)
        return gradient
    }
    
    private func showLoadingGradient() {
        view.layoutIfNeeded() 
        avatarImageView.layer.addSublayer(makeAnimatedGradient(for: avatarImageView, cornerRadius: 35))
        nameLabel.layer.addSublayer(makeAnimatedGradient(for: nameLabel))
        loginNameLabel.layer.addSublayer(makeAnimatedGradient(for: loginNameLabel))
        descriptionLabel.layer.addSublayer(makeAnimatedGradient(for: descriptionLabel))
    }
    
    private func removeLoadingGradients() {
        for layer in animationLayers {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    }
