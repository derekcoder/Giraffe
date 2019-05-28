//
//  Response.swift
//  Giraffe
//
//  Created by derekcoder on 8/4/19.
//

import Foundation

public struct Response<A> {
    public var result: Result<A, APIError>
    
    public let data: Data?
    public let error: Error?
    public let httpResponse: HTTPURLResponse?
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
