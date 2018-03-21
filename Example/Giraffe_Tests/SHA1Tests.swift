//
//  SHA1Tests.swift
//  Giraffe_Tests
//
//  Created by Derek on 21/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Giraffe

class SHA1Tests: XCTestCase {
    func testStringSha() {
        let string = "abc"
        XCTAssertEqual(SHA1.hexString(from: string), "A9993E36 4706816A BA3E2571 7850C26C 9CD0D89D")
    }
}
