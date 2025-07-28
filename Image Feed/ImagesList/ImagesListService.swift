//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 7/1/25.
//
import Foundation
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var isFetching = false
    private var lastLoadedPage = 0
    private let jsonDecoder = JSONDecoder()
    
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        
        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)"
        
        guard let url = URL(string: urlString) else {
            isFetching = false
            return
        }
        
        var request = URLRequest(url: url)

        // ✅ Теперь используем токен авторизации OAuth
        guard let token = OAuth2TokenStorage.shared.token else {
            print("❌ Нет токена для запроса фото")
            isFetching = false
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isFetching = false }
            guard let self = self, let data = data, error == nil else { return }
            
            do {
                print(String(data: data, encoding: .utf8) ?? "нет данных")
                let results = try self.jsonDecoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = results.map { result -> Photo in
                    let size = CGSize(width: result.width, height: result.height)
                    let date = result.createdAt.flatMap { self.dateFormatter.date(from: $0) }
                    
                    return Photo(
                        id: result.id,
                        size: size,
                        createdAt: date,
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.regular,
                        fullImageURL: result.urls.full,
                        isLiked: result.likedByUser
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                }
            } catch {
                print("Error decoding: \(error)")
                print(String(data: data, encoding: .utf8) ?? "нет данных")
            }
        }
        
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "No token", code: 401)))
            return
        }
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            DispatchQueue.main.async {
                guard let self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                
                completion(.success(()))
            }
        }
        
        task.resume()
    }
    
    func reset() {
        photos = []
        lastLoadedPage = 0
        isFetching = false
    }
}
