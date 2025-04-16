import UIKit

final class ProfileViewController: UIViewController {

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 36 // половина от width/height (72/2)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "rectangle.portrait.and.arrow.forward")
        button.setImage(image, for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        setupConstraints()
    }

    @objc private func didTapLogoutButton() {
        print("Logout tapped")
        // Добавь логику выхода
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Logout button — по правому верхнему углу
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Avatar — по левому краю
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 72),
            avatarImageView.heightAnchor.constraint(equalToConstant: 72),

            // Name — под аватаром, по левому краю
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Login name — под именем, по левому краю
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Description — под логином, по левому краю
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
    }

}
