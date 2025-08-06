//
//  ImagesListViewControllerProtocol.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableAnimated(oldCount: Int, newCount: Int)
    func reloadRow(at index: Int)
    func showLikeError()
}
