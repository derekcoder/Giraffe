//
//  Resource.swift
//  Giraffe
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

import Foundation

public struct Resource<A> {
  public var url: URL
  public var method: HTTPMethod<Data?> = .get
  public var parse: (Data?) -> Result<A, APIError>
  public var headers: Headers? = nil
  public var parameters: Parameters? = nil
  public var timeoutInterval: TimeInterval? = nil
}

public extension Resource {
  init(url: URL, method: HTTPMethod<Data?> = .get, parse: @escaping (Data?) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parse = parse
  }
  
  init(url: URL, method: HTTPMethod<Data?> = .get, parseJSON: @escaping (Any) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parse = { data in
      guard let data = data,
        let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
          return Result.failure(.invalidResponse)
      }
      return parseJSON(obj)
    }
  }
  
  init(url: URL, jsonMethod: HTTPMethod<Any>, parse: @escaping (Data?) -> Result<A, APIError>) {
    self.url = url
    self.parse = parse
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
  }
  
  init(url: URL, jsonMethod: HTTPMethod<Any>, parseJSON: @escaping (Any) -> Result<A, APIError>) {
    self.url = url
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    self.parse = { data in
      guard let data = data,
        let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
          return Result.failure(.invalidResponse)
      }
      return parseJSON(obj)
    }
  }
}

public extension Resource {
  var requestURL: URL {
    if var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let parameters = parameters,
      !parameters.isEmpty {
      
      let queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
      urlComponent.queryItems = queryItems
      
      if let newURL = urlComponent.url {
        return newURL
      }
    }
    return url
  }
}
