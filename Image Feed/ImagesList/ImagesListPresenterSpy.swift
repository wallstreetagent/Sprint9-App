//
//  ImagesListPresenterSpy.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private(set) var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
