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
        
        // Check if the current request is successful.
        let statusCode = httpResponse.statusCode
        if !((200...299).contains(statusCode)) {
            // status code not in 200..<300
            // return response with .apiFailed error.
            let response = Response<A>(result: .failure(.apiFailed(statusCode)),
                                       data: data,
                                       error: error,
                                       httpResponse: httpResponse)
            
            CallbackQueue.mainAsync.execute { completion(response) }
        } else {
            // status code in 200..<300
            // call resource' parse to get result, then return response
            // in the resource's parse, maybe get .invalidResponse error
            CallbackQueue.globalAsync.execute {
                let result = resource.parse(data)
                let response = Response<A>(result: result,
                                           data: data,
                                           error: error,
                                           httpResponse: httpResponse)
                
                CallbackQueue.mainAsync.execute { completion(response) }
            }
        }
    }
}
