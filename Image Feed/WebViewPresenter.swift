//
//  WebViewPresenter.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/1/25.
//

import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol = AuthHelper()) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        let request = authHelper.authRequest()
        view?.load(request: request)
        didUpdateProgressValue(0) // сразу показываем прогресс
    }

    func didUpdateProgressValue(_ newValue: Double) {
        view?.setProgressValue(Float(newValue))
        let shouldHide = newValue >= 1.0
        view?.setProgressHidden(shouldHide)
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
