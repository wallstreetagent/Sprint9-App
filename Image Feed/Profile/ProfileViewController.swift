import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfile(name: String, login: String, bio: String?)
    func updateAvatar(url: URL)
    func showLoadingState()
    func hideLoadingState()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    @IBOutlet  var avatarImageView: UIImageView!
    @IBOutlet  var nameLabel: UILabel!
    @IBOutlet  var loginNameLabel: UILabel!
    @IBOutlet  var descriptionLabel: UILabel!
    @IBOutlet  var logoutButton: UIButton!

    private var animationLayers = Set<CALayer>()
    private var presenter: ProfilePresenterProtocol!

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    func updateProfile(name: String, login: String, bio: String?) {
        nameLabel.text = name
        loginNameLabel.text = login
        descriptionLabel.text = bio ?? ""
    }

    func updateAvatar(url: URL) {
        avatarImageView.kf.setImage(with: url)
    }

    func showLoadingState() {
        showLoadingGradient()
    }

    func hideLoadingState() {
        removeLoadingGradients()
    }

    @IBAction private func didTapLogout(_ sender: UIButton) {
        presenter.logoutTapped()
    }

    // MARK:
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
