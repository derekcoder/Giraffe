//
//  Result.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

// Referenced from https://talk.objc.io/

import Foundation

public enum Result<A> {
    case success(A)
    case failure(Swift.Error)
}

extension Result {
    public init(error: Swift.Error) {
        self = .failure(error)
    }
    
    public init(value: A) {
        self = .success(value)
    }
    
    public var value: A? {
        guard case .success(let v) = self else { return nil }
        return v
    }
    
    public var error: Swift.Error? {
        guard case .failure(let e) = self else { return nil }
        return e
    }
}
