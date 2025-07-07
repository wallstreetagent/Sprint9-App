//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 5/30/25.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    static let shared = ProfileImageService()
    private init() {}

    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?

    private struct UserResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }

        struct ProfileImage: Codable {
            let small: String
        }
    }

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if task != nil, username == lastUsername {
            print("ℹ️ Запрос кэширован — не повторяем")
            return
        }

        task?.cancel()
        lastUsername = username

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("❌ Неверный URL для профиля: \(username)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let token = OAuth2TokenStorage.shared.token else {
            print("❌ Нет токена для запроса аватарки")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.task = nil
                self?.lastUsername = nil
            }

            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                print("⚠️ Запрос аватарки отменён")
                return
            }

            if let error = error {
                print("❌ Ошибка при получении аватарки: \(error)")
                completion(.failure(error))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data = data
            else {
                print("❌ Неверный ответ от сервера при загрузке аватарки")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                let result = try JSONDecoder().decode(UserResult.self, from: data)
                let urlString = result.profileImage.small
                self?.avatarURL = urlString
                print("✅ Аватарка успешно получена: \(urlString)")
                completion(.success(urlString))

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": urlString]
                )
            } catch {
                print("❌ Ошибка декодирования JSON с аватаркой: \(error)")
                completion(.failure(error))
            }
        }

        task?.resume()
    }
}
