//
//  ImagesListPresenterSpy.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

@testable import Image_Feed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private(set) var viewDidLoadCalled = false
    private(set) var likeTappedIndex: Int?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photoCount() -> Int {
        return 0
    }

    func photo(at index: Int) -> Photo {
        return Photo(id: "1", size: .init(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
    }

    func didTapLike(at index: Int) {
        likeTappedIndex = index
    }
}
