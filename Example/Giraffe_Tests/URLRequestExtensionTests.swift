//
//  URLRequestExtensionTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

class URLRequestExtensionTests: XCTestCase {

    func testInitWithResourceHeaders() {
        let url = URL(string: "https://www.appple.com")!
        var resource = Resource(url: url, parse: { _ in return Result.success(1) })
        let headers: Headers? = [.authorization: "a"]
        
        var request = URLRequest(resource: resource, headers: headers, timeoutInterval: 10)
        XCTAssertEqual(request.url, resource.requestURL)
        XCTAssertEqual(request.timeoutInterval, 10)
        XCTAssertTrue(request.allHTTPHeaderFields!.contains { $0 == HTTPRequestHeaderField.authorization.key && $1 == "a" })
        
        resource.timeoutInterval = 30
        resource.headers = [.accept: "b"]
        request = URLRequest(resource: resource, headers: headers, timeoutInterval: 20)
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertTrue(request.allHTTPHeaderFields!.contains { $0 == HTTPRequestHeaderField.accept.key && $1 == "b" })
    }
    
    private func generateURLRequest(method: HTTPMethod<Data?>) -> URLRequest {
        let url = URL(string: "https://www.appple.com")!
        let resource = Resource(url: url, method: method, parse: { _ in return Result.success(1) })
        return URLRequest(resource: resource, timeoutInterval: 10)
    }
    
    func testConfigureBody() {
        let data = try! JSONSerialization.data(withJSONObject: ["count": 3], options: [])
        
        // GET method
        var request = generateURLRequest(method: .get)
        XCTAssertNil(request.httpBody)
        
        // POST method
        request = generateURLRequest(method: .post(data: data))
        XCTAssertEqual(request.httpBody, data)
        
        request = generateURLRequest(method: .post(data: nil))
        XCTAssertNil(request.httpBody)
        XCTAssertTrue(request.allHTTPHeaderFields!.contains { $0 == HTTPRequestHeaderField.contentLength.key && $1 == "0" })
        
        // PUT method
        request = generateURLRequest(method: .put(data: data))
        XCTAssertEqual(request.httpBody, data)
        
        request = generateURLRequest(method: .put(data: nil))
        XCTAssertNil(request.httpBody)
        XCTAssertTrue(request.allHTTPHeaderFields!.contains { $0 == HTTPRequestHeaderField.contentLength.key && $1 == "0" })
        
        // PATCH method
        request = generateURLRequest(method: .patch(data: data))
        XCTAssertEqual(request.httpBody, data)
        
        request = generateURLRequest(method: .patch(data: nil))
        XCTAssertNil(request.httpBody)
        XCTAssertTrue(request.allHTTPHeaderFields!.contains { $0 == HTTPRequestHeaderField.contentLength.key && $1 == "0" })
    }
    
    func testSetHeaderValue() {
        var request = generateURLRequest(method: .get)
        request.setHeaderValue("a", for: .authorization)
        XCTAssertTrue(request.allHTTPHeaderFields!.contains { $0 == HTTPRequestHeaderField.authorization.key && $1 == "a" })
    }
    
    func testHeaderValue() {
        var request = generateURLRequest(method: .get)
        request.setHeaderValue("a", for: .authorization)
        XCTAssertEqual(request.headerValue(for: .authorization), "a")
    }
}
