//
//  ImagesListPresenter.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []

    func viewDidLoad() {
        print("🎬 Presenter viewDidLoad called")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        imagesListService.fetchPhotosNextPage()
    }

    @objc private func didChangePhotos() {
        print("📸 Photos loaded: \(photos.count)")
        print("photos count:", photos.count)
        let oldCount = photos.count
        photos = imagesListService.photos
        print("✅ Photos loaded: \(photos.count)")
        view?.updateTableAnimated(oldCount: oldCount, newCount: photos.count)
    }

    func photoCount() -> Int {
        photos.count
    }

    func photo(at index: Int) -> Photo {
        photos[index]
    }

    func didTapLike(at index: Int) {
        let photo = photos[index]
        let newIsLiked = !photo.isLiked

        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let updatedPhoto):
                self.photos[index] = updatedPhoto
                self.view?.reloadRow(at: index)
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
}
