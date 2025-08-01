//
//  WebViewViewControllerSpy.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/1/25.
//

import Foundation
@testable import Image_Feed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {
        // не нужен для этого теста
    }

    func setProgressHidden(_ isHidden: Bool) {
        // не нужен для этого теста
    }
}
