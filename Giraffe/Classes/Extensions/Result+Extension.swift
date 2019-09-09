//
//  Result+Extension.swift
//  Giraffe
//
//  Created by Derek on 11/6/19.
//

import Foundation

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
