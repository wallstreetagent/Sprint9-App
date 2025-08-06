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
        guard let token = OAuth2TokenStorage.shared.token else {
            isFetching = false
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self, let data, error == nil else {
                self?.isFetching = false
                return
            }
            
            do {
                let results = try self.jsonDecoder.decode([PhotoResult].self, from: data)
                let newPhotos = results.map {
                    Photo(
                        id: $0.id,
                        size: CGSize(width: $0.width, height: $0.height),
                        createdAt: $0.createdAt.flatMap { self.dateFormatter.date(from: $0) },
                        welcomeDescription: $0.description,
                        thumbImageURL: $0.urls.thumb,
                        largeImageURL: $0.urls.regular,
                        fullImageURL: $0.urls.full,
                        isLiked: $0.likedByUser
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.isFetching = false
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                }
            } catch {
                self.isFetching = false
                print("Decoding error: \(error)")
            }
        }
        
        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Photo, Error>) -> Void) {
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

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var photo = self.photos[index]
                    photo.isLiked = isLike
                    self.photos[index] = photo
                    completion(.success(photo))
                } else {
                    completion(.failure(NSError(domain: "Photo not found", code: 404)))
                }
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
