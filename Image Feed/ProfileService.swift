//
//  ProfileService.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 5/28/25.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService() // Синглтон

    private var task: URLSessionTask?
    private(set) var profile: Profile?

    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?

        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }

    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.task = nil }

            if let error = error as NSError?, error.code == NSURLErrorCancelled { return }

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
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                let name = [profileResult.firstName, profileResult.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                let profile = Profile(
                    username: profileResult.username,
                    name: name,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )

                self?.profile = profile
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }

        task?.resume()
    }
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
}
