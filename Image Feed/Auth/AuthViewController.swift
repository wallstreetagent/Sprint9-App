import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
            
            let presenter = WebViewPresenter()
                    webViewViewController.presenter = presenter
                    presenter.view = webViewViewController
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("delegate is nil? \(delegate == nil)")
        print("Передан код \(code)")
        vc.dismiss(animated: true)

        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                print("✅ Токен успешно получен: \(token)")
                print("Отправляю делегату токен в SplashViewController")
                self.delegate?.authViewController(self, didAuthenticateWithCode: token)

            case .failure(let error):
                print("❌ Ошибка авторизации: \(error.localizedDescription)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("❌ Пользователь отменил авторизацию")
        dismiss(animated: true)
    }
}
