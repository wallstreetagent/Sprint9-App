import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
 
    private let profileService = ProfileService.shared
    
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
            
            guard let token = OAuth2TokenStorage.shared.token else {
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
                selector: #selector(updateAvatar(_:)),
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

    @objc private func updateAvatar(_ notification: Notification) {
        DispatchQueue.main.async {
            guard self.isViewLoaded else { return }

            if let profileImageURL = notification.userInfo?["URL"] as? String {
                
                self.avatarImageView.kf.setImage(with: URL(string: profileImageURL))
            }
        }
    }

    
    }
