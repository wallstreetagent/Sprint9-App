
// file name: OAuth2Service
//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 5/28/25.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

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
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("❌ Ошибка: неверный URL")
            return nil
        }

        var request = URLRequest(url: url)
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
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        return request
    }

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if let task = task {
            if lastCode == code {
                print("⚠️ Повторный запрос с тем же кодом — отмена")
                completion(.failure(NetworkError.invalidRequest))
                return
            } else {
                task.cancel()
            }
        } else {
            if lastCode == code {
                print("⚠️ Повторный код авторизации — отмена")
                completion(.failure(NetworkError.invalidRequest))
                return
            }
        }

        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ Не удалось создать запрос для получения токена")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }

            self.task = nil
            self.lastCode = nil

            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = responseBody.accessToken
                    print("✅ Токен успешно получен: \(responseBody.accessToken)")
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("❌ Ошибка декодирования токена: \(error)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("❌ Ошибка получения токена: \(error)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }
}
