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
  public var parse: ((HTTPURLResponse) -> Result<A, APIError>)?
  public var parseData: ((Data?, HTTPURLResponse) -> Result<A, APIError>)?
  public var parseJSON: ((Any, HTTPURLResponse) -> Result<A, APIError>)?
  
  public var headers: Headers? = nil
  public var parameters: Parameters? = nil
  public var timeoutInterval: TimeInterval? = nil
}

public extension Resource {
  init(url: URL, method: HTTPMethod<Data?> = .get, parse: @escaping (HTTPURLResponse) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parse = parse
  }
  
  init(url: URL, method: HTTPMethod<Data?> = .get, parseData: @escaping (Data?) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parseData = { data, _ in parseData(data) }
  }
  
  init(url: URL, method: HTTPMethod<Data?> = .get, parseData: @escaping (Data?, HTTPURLResponse) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parseData = parseData
  }
  
  init(url: URL, method: HTTPMethod<Data?> = .get, parseJSON: @escaping (Any) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parseJSON = { obj, _ in parseJSON(obj) }
  }
      
  init(url: URL, method: HTTPMethod<Data?> = .get, parseJSON: @escaping (Any, HTTPURLResponse) -> Result<A, APIError>) {
    self.url = url
    self.method = method
    self.parseJSON = parseJSON
  }
  
  init(url: URL, jsonMethod: HTTPMethod<Any>, parse: @escaping (HTTPURLResponse) -> Result<A, APIError>) {
    self.url = url
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    self.parse = parse
  }

  init(url: URL, jsonMethod: HTTPMethod<Any>, parseData: @escaping (Data?) -> Result<A, APIError>) {
    self.url = url
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    self.parseData = { data, _ in parseData(data) }
  }
  
  init(url: URL, jsonMethod: HTTPMethod<Any>, parseData: @escaping (Data?, HTTPURLResponse) -> Result<A, APIError>) {
    self.url = url
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    self.parseData = parseData
  }
  
  init(url: URL, jsonMethod: HTTPMethod<Any>, parseJSON: @escaping (Any) -> Result<A, APIError>) {
    self.url = url
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    self.parseJSON = { obj, _ in parseJSON(obj) }
  }
  
  init(url: URL, jsonMethod: HTTPMethod<Any>, parseJSON: @escaping (Any, HTTPURLResponse) -> Result<A, APIError>) {
    self.url = url
    self.method = jsonMethod.map { jsonObject in
      try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    self.parseJSON = parseJSON
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
