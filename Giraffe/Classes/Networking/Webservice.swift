//
//  Webservice.swift
//  Giraffe
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

import Foundation

public final class Webservice {
  public let session: URLSession
  public var headers: Headers = [.contentType: MediaType.appJSON.rawValue,
                                 .accept: MediaType.appJSON.rawValue]
  public var timeoutInterval: TimeInterval = 60 // in seconds
  
  public init() {
    let sessionConfig = URLSessionConfiguration.default
    self.session = URLSession(configuration: sessionConfig)
  }
  
  @discardableResult
  public func load<A>(_ resource: Resource<A>,
                      completion: @escaping (Response<A>) -> ()) -> URLSessionDataTask {
    
    let request = URLRequest(resource: resource,
                             headers: headers,
                             timeoutInterval: timeoutInterval)
    
    let task = session.dataTask(with: request, completionHandler: {
      [weak self] data, response, error in
      
      self?.handleResponse(response,
                           resource: resource,
                           data: data,
                           error: error,
                           completion: completion)
    })
    task.resume()
    return task
  }
  
  func handleResponse<A>(_ response: URLResponse?,
                         resource: Resource<A>,
                         data: Data?,
                         error: Error?,
                         completion: @escaping (Response<A>) -> ()) {
    
    // Check if the request times out.
    guard error?._code != NSURLErrorTimedOut else {
      let response = Response<A>(result: .failure(.requestTimeout),
                                 data: data,
                                 error: error,
                                 httpResponse: nil)
      
      CallbackQueue.mainAsync.execute { completion(response) }
      return
    }
    
    guard let httpResponse = response as? HTTPURLResponse else {
      // If not, return response with .invalidResponse error directly.
      let response = Response<A>(result: .failure(.invalidResponse),
                                 data: data,
                                 error: error,
                                 httpResponse: nil)
      
      CallbackQueue.mainAsync.execute { completion(response) }
      return
    }
    
    let statusCode = httpResponse.statusCode
    let result: Result<A, APIError>
    if let parse = resource.parse {
      result = parse(httpResponse)
    } else if let parseData = resource.parseData {
      if !((200...299).contains(statusCode)) {
        result = .failure(.apiFailed(statusCode))
      } else {
        result = parseData(data)
      }
    } else if let parseJSON = resource.parseJSON {
      if !((200...299).contains(statusCode)) {
        result = .failure(.apiFailed(statusCode))
      } else {
        if let data = data,
          let obj = try? JSONSerialization.jsonObject(with: data, options: []) {
          result = parseJSON(obj)
        } else {
          result = .failure(.invalidResponse)
        }
      }
    } else {
      fatalError()
    }
    
    let response = Response<A>(
      result: result,
      data: data,
      error: error,
      httpResponse: httpResponse)
    
    CallbackQueue.mainAsync.execute { completion(response) }
  }
}
