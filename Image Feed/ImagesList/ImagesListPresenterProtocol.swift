

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func photoCount() -> Int
    func photo(at index: Int) -> Photo
    func didTapLike(at index: Int)
}
