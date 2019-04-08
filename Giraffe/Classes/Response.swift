//
//  Response.swift
//  Giraffe
//
//  Created by derekcoder on 8/4/19.
//

import Foundation

struct Response<Value> {
    let result: Result<Value>
    let httpResponse: HTTPURLResponse?
    let isCached: Bool
}
