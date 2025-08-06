//
//  ImagesListViewControllerTests.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

@testable import Image_Feed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {

    func testTableViewExistsAndLoads() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController


        _ = sut.view


        XCTAssertNotNil(sut.tableView, "Таблица должна существовать")


        let rows = sut.tableView.numberOfRows(inSection: 0)
        XCTAssertTrue(rows >= 0, "Количество строк должно быть неотрицательным")
    }
}
