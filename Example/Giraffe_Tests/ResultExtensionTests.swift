//
//  ResponseTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

class ResultExtensionTests: XCTestCase {
    
    func testValue() {
        var result: Result<Int, APIError> = .success(1)
        XCTAssertEqual(result.value, 1)
        
        result = .failure(.invalidResponse)
        XCTAssertNil(result.value)
    }
    
    func testError() {
        var result: Result<Int, APIError> = .failure(.invalidResponse)
        XCTAssertEqual(result.error, APIError.invalidResponse)
        
        result = .success(1)
        XCTAssertNil(result.error)
    }
}
