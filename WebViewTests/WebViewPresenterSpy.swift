//
//  WebViewPresenterSpy.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/1/25.
//

import Foundation
@testable import Image_Feed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {

    }

    func code(from url: URL) -> String? {
        return nil
    }
}
