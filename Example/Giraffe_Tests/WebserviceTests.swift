//
//  WebserviceTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

class WebserviceTests: XCTestCase {
  private let webservice = Webservice()
  private static let url = URL(string: "https://www.apple.com")!
  private let resource = Resource<Int>(url: WebserviceTests.url, parse: { _ in return Result.success(1) })
  
  func testInit() {
    XCTAssertEqual(webservice.headers.count, 2)
    XCTAssertTrue(webservice.headers.contains { $0 == HTTPRequestHeaderField.contentType && $1 == MediaType.appJSON.rawValue })
    XCTAssertTrue(webservice.headers.contains { $0 == HTTPRequestHeaderField.accept && $1 == MediaType.appJSON.rawValue })
    XCTAssertEqual(webservice.timeoutInterval, 60)
  }
  
  func testHandleResponseFailedDueToTimeout() {
    let error = NSError(domain: "com.derekcoder.Giraffe", code: NSURLErrorTimedOut, userInfo: nil)
    
    let expectation = XCTestExpectation(description: "The request should fail due to the timeout")
    
    webservice.handleResponse(nil, resource: resource, data: nil, error: error, completion: { response in
      
      XCTAssertEqual(response.result.error, APIError.requestTimeout)
      XCTAssertNil(response.httpResponse)
      XCTAssertNil(response.data)
      XCTAssertEqual(response.error?._code, error.code)
      expectation.fulfill()
    })
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testHandleResponseFailedDueToNotHTTPURLResponse() {
    let urlResponse = URLResponse(url: resource.url, mimeType: nil, expectedContentLength: 10, textEncodingName: nil)
    
    let expectation = XCTestExpectation(description: "The request should fail due to not HTTPURLResponse")
    
    webservice.handleResponse(urlResponse, resource: resource, data: nil, error: nil, completion: { response in
      
      XCTAssertEqual(response.result.error, APIError.invalidResponse)
      XCTAssertNil(response.httpResponse)
      XCTAssertNil(response.data)
      XCTAssertNil(response.error)
      expectation.fulfill()
    })
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testHandleResponseFailedDueToStatusCode() {
    let httpResponse = HTTPURLResponse(url: resource.url, statusCode: 300, httpVersion: nil, headerFields: nil)!
    let resource = Resource<Int>(url: WebserviceTests.url, parseData: { _ in return Result.success(1) })

    let expectation = XCTestExpectation(description: "The request should fail due to status code not in (200...299)")
    
    webservice.handleResponse(
      httpResponse,
      resource: resource,
      data: nil,
      error: nil,
      completion: { response in
        
        XCTAssertEqual(response.result.error, APIError.apiFailed(300))
        XCTAssertEqual(response.httpResponse, httpResponse)
        XCTAssertNil(response.data)
        XCTAssertNil(response.error)
        expectation.fulfill()
    })
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testHandleResponseSucceed() {
    let httpResponse = HTTPURLResponse(url: resource.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    
    let expectation = XCTestExpectation(description: "Request should succeed")
    
    webservice.handleResponse(
      httpResponse,
      resource: resource,
      data: nil,
      error: nil,
      completion: { response in
        
        XCTAssertEqual(response.result.value, 1)
        XCTAssertEqual(response.httpResponse, httpResponse)
        XCTAssertNil(response.data)
        XCTAssertNil(response.error)
        expectation.fulfill()
    })
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testSucceedGETRequest() {
    let expectation = XCTestExpectation(description: "The GET request should succeed")
    
    webservice.load(Post.postsResource) { response in
      XCTAssertNotNil(response.result.value)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
  
  func testSucceedPOSTRequest() {
    let expectation = XCTestExpectation(description: "The POST request should succeed")
    
    let resource = Post.createResource(title: "1", body: "2", userId: 1)
    webservice.load(resource) { response in
      XCTAssertNotNil(response.result.value)
      XCTAssertEqual(response.result.value?.title, "1")
      XCTAssertEqual(response.result.value?.body, "2")
      XCTAssertEqual(response.result.value?.userId, 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
  
  func testSucceedPUTRequest() {
    let expectation = XCTestExpectation(description: "The PUT request should succeed")
    
    let post = Post(id: 1, title: "1", body: "2", userId: 1)
    webservice.load(post.updateResource) { response in
      XCTAssertNotNil(response.result.value)
      XCTAssertEqual(response.result.value, post)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
  
  func testSucceedPATCHRequest() {
    let expectation = XCTestExpectation(description: "The PATCH request should succeed")
    
    let post = Post(id: 1, title: "1", body: "2", userId: 1)
    webservice.load(post.udpateTitleResource) { response in
      XCTAssertNotNil(response.result.value)
      XCTAssertEqual(response.result.value?.id, post.id)
      XCTAssertEqual(response.result.value?.title, post.title)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
  
  func testSucceedDELETERequest() {
    let expectation = XCTestExpectation(description: "The DELETE request should succeed")
    
    let post = Post(id: 1, title: "1", body: "2", userId: 1)
    webservice.load(post.deleteResource) { response in
      XCTAssertNotNil(response.result.value)
      XCTAssertTrue(response.result.value!)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
}

struct Post {
  let id: Int
  let title: String
  let body: String
  let userId: Int
}

extension Post: Equatable {
  static func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.id == rhs.id &&
      lhs.title == rhs.title &&
      lhs.body == rhs.body &&
      lhs.userId == rhs.userId
  }
}

extension Post {
  static var endPoint = URL(string: "https://jsonplaceholder.typicode.com/posts")!
  
  init?(json: JSONDictionary) {
    guard let id = json["id"] as? Int,
      let title = json["title"] as? String,
      let body = json["body"] as? String,
      let userId = json["userId"] as? Int else { return nil }
    self.id = id
    self.title = title
    self.body = body
    self.userId = userId
  }
  
  var json: JSONDictionary {
    return ["id": id, "title": title, "body": body, "userId": userId]
  }
  
  static var postsResource: Resource<[Post]> {
    return Resource<[Post]>(url: Post.endPoint, parseJSON: { obj in
      guard let json = obj as? [JSONDictionary] else {
        return Result.failure(.invalidResponse)
      }
      let posts = json.compactMap(Post.init)
      return Result.success(posts)
    })
  }
  
  static func createResource(title: String, body: String, userId: Int) -> Resource<Post> {
    let data: JSONDictionary = ["title": title, "body": body, "userId": 1]
    return Resource(url: Post.endPoint, jsonMethod: .post(data: data), parseJSON: { obj in
      guard let json = obj as? JSONDictionary,
        let post = Post(json: json) else {
          return Result.failure(.invalidResponse)
      }
      return Result.success(post)
    })
  }
  
  var updateResource: Resource<Post> {
    let url = Post.endPoint.appendingPathComponent("\(id)")
    return Resource(url: url, jsonMethod: .put(data: json), parseJSON: { obj in
      guard let json = obj as? JSONDictionary,
        let post = Post(json: json) else {
          return Result.failure(.invalidResponse)
      }
      return Result.success(post)
    })
  }
  
  var udpateTitleResource: Resource<Post> {
    let url = Post.endPoint.appendingPathComponent("\(id)")
    let data: JSONDictionary = ["title": title]
    return Resource(url: url, jsonMethod: .patch(data: data), parseJSON: { obj in
      guard let json = obj as? JSONDictionary,
        let post = Post(json: json) else {
          return Result.failure(.invalidResponse)
      }
      return Result.success(post)
    })
  }
  
  var deleteResource: Resource<Bool> {
    let url = Post.endPoint.appendingPathComponent("\(id)")
    return Resource(url: url, method: .delete, parse: { _ in
      return Result.success(true)
    })
  }
}
