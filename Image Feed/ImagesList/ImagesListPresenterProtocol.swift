

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }

    func viewDidLoad()
    func photoCount() -> Int
    func photo(at index: Int) -> Photo
    func didTapLike(at index: Int)
}
