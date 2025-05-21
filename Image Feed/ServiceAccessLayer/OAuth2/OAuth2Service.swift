import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
  
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        var request = URLRequest(url: URL(string: "https://unsplash.com/oauth/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]


        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("No response")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1)))
                }
                return
            }

            guard (200...299).contains(response.statusCode) else {
                print("Bad status code: \(response.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: response.statusCode)))
                }
                return
            }

            guard let data = data else {
                print("Empty response data")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1)))
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let token = tokenResponse.accessToken
                self.tokenStorage.token = token
                DispatchQueue.main.async {
                    completion(.success(token))
                }
            } catch {
                print("Failed to decode token: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }
}
