
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {


        if CommandLine.arguments.contains("--uitesting") {
            print("🚀 UI Testing mode: setting test token")
            OAuth2TokenStorage.shared.token = "BQRNvhNmSAGDHuANthPORw5S4pt7_xO9fvq6kd4E0Oo" // твой токен
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
