//
//  HTTPMethod.swift
//  Giraffe
//
//  Created by Derek on 11/6/19.
//

import Foundation

public enum HTTPMethod<A> {
    case get
    case post(data: A)
    case put(data: A)
    case patch(data: A)
    case delete
}

public extension HTTPMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        }
    }
    
    var data: A? {
        switch self {
        case .post(let data): return data
        case .put(let data): return data
        case .patch(let data): return data
        case .get, .delete: return nil
        }
    }
    
    func map<B>(f: (A) throws -> B) rethrows -> HTTPMethod<B> {
        switch self {
        case .get: return .get
        case .post(let data): return .post(data: try f(data))
        case .put(let data): return .put(data: try f(data))
        case .patch(let data): return .patch(data: try f(data))
        case .delete: return .delete
        }
    }
}
