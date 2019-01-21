//
//  Giraffe_Tests.swift
//  Giraffe_Tests
//
//  Created by Derek on 21/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Giraffe

let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!

struct Todo {
    let id: Int
    let title: String
}

extension Todo {
    init?(json: JSONDictionary) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
    
    static let all = Resource<[Todo]>(url: url, parseJSON: { json, _, _, isCached in
        guard let dicts = json as? [JSONDictionary] else {
            return Result(error: GiraffeError.invalidResponse)
        }
        let value = dicts.compactMap(Todo.init)
        return Result(value: value, isCached: isCached)
    })
}


class Giraffe_Tests: XCTestCase {
    
    func testLoad() {
        let expectation = XCTestExpectation(description: "Testing load todos")
        
        let webservice = Webservice()
        webservice.load(Todo.all) { result in
            XCTAssertNotNil(result.value, "No episodes was loaded.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
