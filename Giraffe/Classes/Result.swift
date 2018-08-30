//
//  Result.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public enum Result<A> {
    case success(A)
    case error(Error)
}

extension Result {
    public init(_ value: A?, or error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error)
        }
    }
    
    public init(error: Error) {
        self = .error(error)
    }
    
    public init(_ error: Error) {
        self = .error(error)
    }
    
    public init(value: A) {
        self = .success(value)
    }
    
    public init(_ value: A) {
        self = .success(value)
    }
    
    public var value: A? {
        guard case .success(let v) = self else { return nil }
        return v
    }
    
    public func map<B>(_ transform: (A) throws -> B) rethrows -> Result<B> {
        switch self {
        case .success(let value):
            return .success(try transform(value))
        case .error(let error):
            return .error(error)
        }
    }
}
