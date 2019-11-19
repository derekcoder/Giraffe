//
//  HTTPMethodTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

class HTTPMethodTests: XCTestCase {
  private static let data = try! JSONSerialization.data(withJSONObject: ["count": 3], options: [])
  private let getMethod: HTTPMethod<Data> = .get
  private let postMethod: HTTPMethod<Data> = .post(data: HTTPMethodTests.data)
  private let putMethod: HTTPMethod<Data> = .put(data: HTTPMethodTests.data)
  private let patchMethod: HTTPMethod<Data> = .patch(data: HTTPMethodTests.data)
  private let deleteMethod: HTTPMethod<Data> = .delete
  
  func testMethod() {
    XCTAssertEqual(getMethod.method, "GET")
    XCTAssertEqual(postMethod.method, "POST")
    XCTAssertEqual(putMethod.method, "PUT")
    XCTAssertEqual(patchMethod.method, "PATCH")
    XCTAssertEqual(deleteMethod.method, "DELETE")
  }
  
  func testData() {
    XCTAssertNil(getMethod.data)
    XCTAssertNil(deleteMethod.data)
    XCTAssertEqual(postMethod.data, HTTPMethodTests.data)
    XCTAssertEqual(putMethod.data, HTTPMethodTests.data)
    XCTAssertEqual(patchMethod.data, HTTPMethodTests.data)
  }
}
