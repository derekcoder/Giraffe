//
//  URLRequest+Resource.swift
//  Giraffe
//
//  Created by derekcoder on 27/12/18.
//

import Foundation

public extension URLRequest {
  init<A>(resource: Resource<A>, headers: Headers? = nil, timeoutInterval: TimeInterval) {
    self.init(url: resource.requestURL, timeoutInterval: timeoutInterval)
    
    configureBody(resource: resource)
    
    // global
    headers?.forEach { setHeaderValue($1, for: $0) }
    
    // resource specific
    resource.headers?.forEach { setHeaderValue($1, for: $0) }
    if let timeoutInterval = resource.timeoutInterval {
      self.timeoutInterval = timeoutInterval
    }
  }
}

extension URLRequest {
  mutating func configureBody<A>(resource: Resource<A>) {
    httpMethod = resource.method.method
    if case let .post(data) = resource.method {
      if let data = data {
        httpBody = data
      } else {
        setHeaderValue("0", for: .contentLength)
      }
    } else if case let .put(data) = resource.method {
      if let data = data {
        httpBody = data
      } else {
        setHeaderValue("0", for: .contentLength)
      }
    } else if case let .patch(data) = resource.method {
      if let data = data {
        httpBody = data
      } else {
        setHeaderValue("0", for: .contentLength)
      }
    }
  }
}

public extension URLRequest {
  mutating func setHeaderValue(_ value: String?, for field: HTTPRequestHeaderField) {
    setValue(value, forHTTPHeaderField: field.key)
  }
  
  func headerValue(for field: HTTPRequestHeaderField) -> String? {
    return value(forHTTPHeaderField: field.key)
  }
}
