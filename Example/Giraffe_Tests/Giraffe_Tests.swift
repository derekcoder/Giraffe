//
//  Giraffe_Tests.swift
//  Giraffe_Tests
//
//  Created by Derek on 21/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Giraffe

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

class Giraffe_Tests: XCTestCase {
    
    private let webservice = Webservice()
    
    func testGETMethod() {
        let expectation = XCTestExpectation(description: "Testing request using GET method")
        
        webservice.load(Post.postsResource) { response in
            XCTAssertNotNil(response.result.value)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testPOSTMethod() {
        let expectation = XCTestExpectation(description: "Testing request using POST method")

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
    
    func testPUTMethod() {
        let expectation = XCTestExpectation(description: "Testing request using PUT method")

        let post = Post(id: 1, title: "1", body: "2", userId: 1)
        webservice.load(post.updateResource) { response in
            XCTAssertNotNil(response.result.value)
            XCTAssertEqual(response.result.value, post)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testPATCHMethod() {
        let expectation = XCTestExpectation(description: "Testing request using PATCH method")
        
        let post = Post(id: 1, title: "1", body: "2", userId: 1)
        webservice.load(post.udpateTitleResource) { response in
            XCTAssertNotNil(response.result.value)
            XCTAssertEqual(response.result.value?.id, post.id)
            XCTAssertEqual(response.result.value?.title, post.title)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testDELETEMethod() {
        let expectation = XCTestExpectation(description: "Testing request using DELETE method")
        
        let post = Post(id: 1, title: "1", body: "2", userId: 1)
        webservice.load(post.deleteResource) { response in
            XCTAssertNotNil(response.result.value)
            XCTAssertTrue(response.result.value!)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
