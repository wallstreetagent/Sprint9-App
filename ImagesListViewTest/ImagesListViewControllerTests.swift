//
//  ImagesListViewControllerTests.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

import Foundation
import XCTest
@testable import Image_Feed

final class ImagesListViewControllerTests: XCTestCase {
    func testViewDidLoad_callsPresenter() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        var presenter = ImagesListPresenterSpy()

        sut.configure(presenter)

        // when
        _ = sut.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
