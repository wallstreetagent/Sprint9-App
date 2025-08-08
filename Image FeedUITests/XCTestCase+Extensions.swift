//
//  XCTestCase+Extensions.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/8/25.
//

import XCTest

extension XCUIElement {
    func scrollToElement(in container: XCUIElement, maxSwipes: Int = 10) {
        var swipeCount = 0
        while !self.isHittable && swipeCount < maxSwipes {
            container.swipeUp()
            swipeCount += 1
        }
    }
}
