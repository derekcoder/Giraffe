//
//  Giraffe_Tests.swift
//  Giraffe_Tests
//
//  Created by Derek on 21/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Giraffe

struct Episode {
    let id: String
    let title: String
}

extension Episode: Equatable {
    static func ==(lhs: Episode, rhs: Episode) -> Bool {
        return (lhs.id == rhs.id) && (lhs.title == rhs.title)
    }
}

let url = URL(string: "https://talk.objc.io/episodes.json")!

extension Episode {
    init?(json: JSONDictionary) {
        guard let id = json["id"] as? String,
            let title = json["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
    
    static let all = Resource<[Episode]>(url: url, parseJSON: { (json, _, _) -> Result<[Episode]> in
        guard let dicts = json as? [JSONDictionary] else {
            return Result(error: GiraffeError.invalidResponse)
        }
        let value = dicts.compactMap(Episode.init)
        return Result(value: value)
    })
}

class Giraffe_Tests: XCTestCase {
    
    func testHttpMethod() {
        let json = ["name": "derek"]
        let get = HttpMethod<Any>.get
        let post = HttpMethod<Any>.post(data: json)
        XCTAssertEqual(get.method, "GET")
        XCTAssertEqual(post.method, "POST")
    }
    
    func testHttpMethodMap() {
        let json = ["id": "id"]
        let get = HttpMethod<Any>.get
        let post = HttpMethod<Any>.post(data: json)
        let f: (Any) -> Data = { json in
            return try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        }
        XCTAssertEqual(get.map(f: f).method, "GET")
        XCTAssertEqual(post.map(f: f).method, "POST")
    }
    
    func testResult() {
        let person = Episode(id: "id", title: "title")
        let result = Result(value: person)
        XCTAssertEqual(result.value!, person)
    }
    
    func testURLRequestInitForGet() {
        let resource = Resource<[Episode]>(url: url, method: .get, parseJSON: { (json, _, _) -> Result<[Episode]> in
            guard let dictionaries = json as? [JSONDictionary] else {
                return Result(error: GiraffeError.invalidResponse)
            }
            let value = dictionaries.compactMap(Episode.init)
            return Result(value: value)
        })
        let request = URLRequest(resource: resource, authenticationToken: "token")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"], "token")
    }
    
    func testURLRequestInitForPost() {
        let json = ["id": "id"]
        let method: HttpMethod<Any> = .post(data: json)
        let resource = Resource<[Episode]>(url: url, jsonMethod: method, parseJSON: { (json, _, _) -> Result<[Episode]> in
            guard let dictionaries = json as? [JSONDictionary] else {
                return Result(error: GiraffeError.invalidResponse)
            }
            let value = dictionaries.compactMap(Episode.init)
            return Result(value: value)
        })
        let request = URLRequest(resource: resource)
        XCTAssertEqual(request.httpMethod, "POST")
        
        let data = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        XCTAssertEqual(request.httpBody, data)
    }
    
    func testLoad() {
        let expectation = XCTestExpectation(description: "Testing load episodes")
        
        let webservice = Webservice()
        webservice.load(Episode.all) { result in
            XCTAssertNotNil(result.value, "No episodes was loaded.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
//    func testCachedLoad() {
//        let expectation = XCTestExpectation(description: "Testing cached load episodes")
//        
//        let webservice = Webservice()
//        let cachedWebservice = CachedWebservice(webservice)
//        cachedWebservice.load(Episode.all) { result in
//            XCTAssertNotNil(result.value, "No episodes was loaded.")
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }    
}
