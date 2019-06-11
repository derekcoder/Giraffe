//
//  ParametersExtensionTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

class ParametersExtensionTests: XCTestCase {

    func testAppendingParameters() {
        let parameters1: Parameters = ["a": "1", "b": "2"]
        let parameters2: Parameters = ["c": "3", "b": "4"]
        
        let parameters = parameters1.appendingParameters(parameters2)
        
        XCTAssertEqual(parameters.count, 3)
        XCTAssertTrue(parameters.contains { $0 == "a" && $1 == "1" })
        XCTAssertTrue(parameters.contains { $0 == "b" && $1 == "4" })
        XCTAssertTrue(parameters.contains { $0 == "c" && $1 == "3" })
    }
    
    func testAppendParameters() {
        var parameters: Parameters = ["a": "1", "b": "2"]
        let newParameters: Parameters = ["c": "3", "b": "4"]

        parameters.appendParameters(newParameters)
        
        XCTAssertEqual(parameters.count, 3)
        XCTAssertTrue(parameters.contains { $0 == "a" && $1 == "1" })
        XCTAssertTrue(parameters.contains { $0 == "b" && $1 == "4" })
        XCTAssertTrue(parameters.contains { $0 == "c" && $1 == "3" })
    }
}
