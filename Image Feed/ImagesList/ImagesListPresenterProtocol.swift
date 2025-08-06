//
//  ImagesListPresenterProtocol.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
}

protocol ImagesListViewControllerProtocol: AnyObject {
    func reloadData()
}
