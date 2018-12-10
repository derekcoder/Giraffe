//
//  Webservice.swift
//  SwiftDevHints
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

// Referenced from https://talk.objc.io/

import Foundation

extension URLRequest {
    public init<A>(resource: Resource<A>, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, authenticationToken: String? = nil) {
        self.init(url: resource.url, timeoutInterval: resource.timeoutInterval)
        
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
        
        if let token = authenticationToken {
            setHeaderValue(token, for: .authorization)
        }
        
        if let headers = resource.headers {
            headers.forEach { setHeaderValue($1, for: $0) }
        }
        
        if headerValue(for: .contentType) == nil {
            setHeaderValue(MediaType.appJSON.rawValue, for: .contentType)
        }
        if headerValue(for: .accept) == nil {
            setHeaderValue(MediaType.appJSON.rawValue, for: .accept)
        }
        
        self.cachePolicy = cachePolicy
    }
    
    public mutating func setHeaderValue(_ value: String?, for field: HTTPRequestHeaderField) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }
    
    public func headerValue(for field: HTTPRequestHeaderField) -> String? {
        return value(forHTTPHeaderField: field.rawValue)
    }
}

public final class Webservice {
    public let session: URLSession
    public var configuration: GiraffeConfiguration
        
    public init(configuration: GiraffeConfiguration = GiraffeConfiguration.default) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = configuration.cache
        self.session = URLSession(configuration: sessionConfig)
        self.configuration = configuration
    }
}

extension Webservice {
    public func load<A>(_ resource: Resource<A>, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, completion: @escaping (Result<A>) -> ()) {
        sendRequest(for: resource, cachePolicy: cachePolicy) { result, _ in
            completion(result)
        }
    }
    
    public func load<A>(_ resource: Resource<A>, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        sendRequest(for: resource, cachePolicy: cachePolicy, completion: completion)
    }
    
    private func sendRequest<A>(for resource: Resource<A>, cachePolicy: URLRequest.CachePolicy, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        let request = URLRequest(resource: resource, cachePolicy: cachePolicy, authenticationToken: configuration.authenticationToken)
        session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.global().async {
                let result: Result<A>
                let httpResponse = response as? HTTPURLResponse
                if let httpResponse = httpResponse {
                    result = resource.parse(data, httpResponse, error)
                } else {
                    result = Result(error: GiraffeError.notHTTP)
                }
                DispatchQueue.main.async {
                    completion(result, httpResponse)
                }
            }
        }) .resume()
    }
}
