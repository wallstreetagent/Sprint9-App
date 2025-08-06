//
//  ImagesListViewControllerTests.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

@testable import Image_Feed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        var presenter = ImagesListPresenterSpy()
        sut.configure(presenter)
        
        _ = sut.view // загружаем view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
