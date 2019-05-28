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
    
    static let all = Resource<[Todo]>(url: url, parseJSON: { obj in
        guard let json = obj as? [JSONDictionary] else {
            return Result.failure(.invalidResponse)
        }
        let todos = json.compactMap(Todo.init)
        return Result.success(todos)
    })
}


class Giraffe_Tests: XCTestCase {
    
    func testLoad() {
        let expectation = XCTestExpectation(description: "Testing load todos")
        
        let webservice = Webservice()
        webservice.load(Todo.all) { response in
            XCTAssertNotNil(response.result.value, "No episodes was loaded.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
