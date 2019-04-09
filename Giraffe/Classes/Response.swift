//
//  Response.swift
//  Giraffe
//
//  Created by derekcoder on 8/4/19.
//

import Foundation

public struct Response<Value> {
    let data: Data?
    let error: Error?
    let httpResponse: HTTPURLResponse?
    
    var result: Result<Value, APIError>
    let isCached: Bool
}

public extension Response {
    func jsonObject() throws -> Any {
        if let data = data, error == nil {
            do {
                return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            } catch {
                throw APIError.invalidResponse(data)
            }
        } else {
            throw APIError.invalidResponse(data)
        }
    }
}
