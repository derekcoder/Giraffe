//
//  Response.swift
//  Giraffe
//
//  Created by derekcoder on 8/4/19.
//

import Foundation

public struct ResourceResponse {
    public let data: Data?
    public let httpResponse: HTTPURLResponse
    public let isCached: Bool
}

public struct ResultResponse<Value> {
    public let data: Data?
    public let error: Error?
    public let httpResponse: HTTPURLResponse?
    
    public var result: Result<Value, APIError>
    public let isCached: Bool
}

public extension ResourceResponse {
    var jsonObject: Any? {
        guard let data = data else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
    }
}

public extension Result where Failure == APIError {
    var value: Success? {
        switch self {
        case .failure: return nil
        case .success(let value): return value
        }
    }
    
    var error: APIError? {
        switch self {
        case .failure(let error): return error
        case .success: return nil
        }
    }
}
