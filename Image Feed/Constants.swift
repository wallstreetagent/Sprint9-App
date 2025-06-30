import Foundation

enum Constants {
    static let accessKey = "GkDDtvymFKHbCwm_PaAZD2VrF3yCzhdy2AXkq2f1jcU"
        static let secretKey = "KPPMv8Hgjw8zF_liQS4ZX6GELcYuDhFnHVq4WnNgu8A"
        static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
        static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
            guard let url = URL(string: "https://api.unsplash.com") else {
                fatalError("❌ Invalid URL string in Constants.defaultBaseURL")
            }
            return url
        }()
}
