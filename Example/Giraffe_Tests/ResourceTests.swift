//
//  ResourceExtensionTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

/*
class ResourceTests: XCTestCase {
  private static let json: JSONDictionary = ["count": 3]
  private let url: URL = URL(string: "https://www.apple.com")!
  private let method: HTTPMethod<Data?> = .get
  private let jsonMethod: HTTPMethod<Any> = .post(data: ResourceTests.json)
  private let parse: (Data?, HTTPURLResponse) -> Result<Int, APIError> = { data, _ in
    return Result.success(2)
  }
  private let parseJSON: (Any) -> Result<Int, APIError> = { obj in
    let json = obj as! JSONDictionary
    let count = json["count"] as! Int
    return Result.success(count)
  }
  private let data = try! JSONSerialization.data(withJSONObject: ResourceTests.json, options: [])
  
  func testInitWithURLMethodParse() {
    let resource = Resource(url: url, method: method, parse: parse)
    XCTAssertEqual(resource.url, url)
    XCTAssertEqual(resource.method.method, method.method)
//    XCTAssertEqual(resource.parse(nil).value, parse(nil).value)
    XCTAssertNil(resource.headers)
    XCTAssertNil(resource.parameters)
    XCTAssertNil(resource.timeoutInterval)
  }
  
  func testInitWithURLMethodParseJSON() {
    let resource = Resource(url: url, method: method, parseJSON: parseJSON)
    XCTAssertEqual(resource.url, url)
    XCTAssertEqual(resource.method.method, method.method)
//    XCTAssertEqual(resource.parse(data).value, parseJSON(ResourceTests.json).value)
//    XCTAssertEqual(resource.parse(nil).error, APIError.invalidResponse)
    XCTAssertNil(resource.headers)
    XCTAssertNil(resource.parameters)
    XCTAssertNil(resource.timeoutInterval)
  }
  
  func testInitWithURLJSONMethodParse() {
    let resource = Resource(url: url, jsonMethod: jsonMethod, parse: parse)
    XCTAssertEqual(resource.url, url)
    XCTAssertEqual(resource.method.method, jsonMethod.method)
    XCTAssertEqual(resource.method.data, data)
//    XCTAssertEqual(resource.parse(nil).value, parse(nil).value)
    XCTAssertNil(resource.headers)
    XCTAssertNil(resource.parameters)
    XCTAssertNil(resource.timeoutInterval)
  }
  
  func testInitWithURLJSONMethodParseJSON() {
    let resource = Resource(url: url, jsonMethod: jsonMethod, parseJSON: parseJSON)
    XCTAssertEqual(resource.url, url)
    XCTAssertEqual(resource.method.method, jsonMethod.method)
    XCTAssertEqual(resource.method.data, data)
//    XCTAssertEqual(resource.parse(data).value, parseJSON(ResourceTests.json).value)
//    XCTAssertEqual(resource.parse(nil).error, APIError.invalidResponse)
    XCTAssertNil(resource.headers)
    XCTAssertNil(resource.parameters)
    XCTAssertNil(resource.timeoutInterval)
  }
  
  func testRequstURL() {
    var resource = Resource(url: url, method: method, parse: parse)
    XCTAssertEqual(resource.requestURL, resource.url)
    
    resource.parameters = [:]
    XCTAssertEqual(resource.requestURL, resource.url)
    
    resource.parameters = ["page": "1", "username": "a"]
    let urlComponent = URLComponents(url: resource.requestURL,
                                     resolvingAgainstBaseURL: false)!
    XCTAssertEqual(urlComponent.queryItems!.count, 2)
    XCTAssertTrue(urlComponent.queryItems!.contains { ($0.name == "page" && $0.value == "1") })
    XCTAssertTrue(urlComponent.queryItems!.contains { ($0.name == "username" && $0.value == "a") })
  }
}
*/
