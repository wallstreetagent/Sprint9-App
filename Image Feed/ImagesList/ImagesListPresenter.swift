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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        imagesListService.fetchPhotosNextPage()
    }

    @objc private func didChangePhotos() {
        let oldCount = photos.count
        photos = imagesListService.photos
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
