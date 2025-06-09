//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 5/30/25.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    static let shared = ProfileImageService() // синглтон
    private init() {} // приватный инициализатор

    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?

    // Структура для декодирования ответа
    private struct UserResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }

        struct ProfileImage: Codable {
            let small: String
        }
    }

    // Метод для получения URL аватарки
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        // Предотвращаем гонку запросов: если запрашивается тот же username — игнорируем
        if task != nil, username == lastUsername {
            return
        }

        task?.cancel()
        lastUsername = username

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.task = nil
                self?.lastUsername = nil
            }

            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                return
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data = data
            else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                let result = try JSONDecoder().decode(UserResult.self, from: data)
                let urlString = result.profileImage.small
                self?.avatarURL = urlString
                completion(.success(urlString))
                
                NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": urlString]
                    )
                } catch {
                    completion(.failure(error))
                }
        }

        task?.resume()
    }
}

