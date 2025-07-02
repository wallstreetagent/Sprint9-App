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

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true

        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Client-ID ВАШ_КЛЮЧ", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isFetching = false }
            guard let self = self, let data = data, error == nil else { return }

            do {
                let results = try JSONDecoder().decode([PhotoResult].self, from: data)

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
            }
        }

        task.resume()
    }
}
