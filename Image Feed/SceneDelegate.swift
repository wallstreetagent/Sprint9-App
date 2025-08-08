import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Убираем токен, чтобы UI тест начинался с авторизации
        if CommandLine.arguments.contains("--uitesting") {
            print("🚀 UI Testing mode: clearing token for UI test")
            OAuth2TokenStorage.shared.token = nil
        }

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        if let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController {
            window.rootViewController = splashVC
        }

        self.window = window
        window.makeKeyAndVisible()
    }
}
