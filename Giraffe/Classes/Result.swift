//
//  Result.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

/*
public enum Result<A> {
    case success(A, isCached: Bool)
    case failure(Swift.Error)
}

extension Result {
    public init(error: Swift.Error) {
        self = .failure(error)
    }
    
    public init(value: A, isCached: Bool) {
        self = .success(value, isCached: isCached)
    }
    
    public var value: A? {
        guard case let .success(v, _) = self else { return nil }
        return v
    }
    
    public var error: Swift.Error? {
        guard case .failure(let e) = self else { return nil }
        return e
    }
}*/

/*
extension Resource {
    func parse(data: Data?, response: URLResponse?, error: Error?, isCached: Bool) -> Result<A> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return Result(error: GiraffeError.notHTTP)
        }
        let result = parse(data, httpResponse, error, isCached)
        return result
    }
}*/
