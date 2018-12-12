//
//  Webservice.swift
//  SwiftDevHints
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

// Referenced from https://talk.objc.io/

import Foundation

public extension URLRequest {
    init<A>(resource: Resource<A>, authenticationToken: String? = nil) {
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
    }
    
    mutating func setHeaderValue(_ value: String?, for field: HTTPRequestHeaderField) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }
    
    func headerValue(for field: HTTPRequestHeaderField) -> String? {
        return value(forHTTPHeaderField: field.rawValue)
    }
}

public final class Webservice {
    public let session: URLSession
    public var configuration: GiraffeConfiguration
        
    public init(configuration: GiraffeConfiguration = GiraffeConfiguration.default) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = nil
        self.session = URLSession(configuration: sessionConfig)
        self.configuration = configuration
    }
}

extension Webservice {
    public func load<A>(_ resource: Resource<A>, cacheMode: CacheMode = .onlyReload, completion: @escaping (Result<A>) -> ()) {
        sendRequest(for: resource, cacheMode: cacheMode) { result, _ in
            completion(result)
        }
    }
    
    public func load<A>(_ resource: Resource<A>, cacheMode: CacheMode = .onlyReload, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        sendRequest(for: resource, cacheMode: cacheMode, completion: completion)
    }
    
    private func sendRequest<A>(for resource: Resource<A>, cacheMode: CacheMode, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: configuration.authenticationToken)
        
        guard let url = request.url else {
            completion(Result(error: GiraffeError.invalidRequest), nil)
            return
        }
        
        switch cacheMode {
        case .onlyReload:
            session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                guard let self = self else { return }
                DispatchQueue.global().async {
                    let result = self.generateResult(resource: resource, data: data, response: response, error: error)
                    
                    if let data = data {
                        self.configuration.newCache.store(data: data, forKey: url.absoluteString)
                    }
                    DispatchQueue.main.async {
                        completion(result.0, result.1)
                    }
                }
            }).resume()
        case .onlyCache:
            if let data = configuration.newCache.data(forKey: url.absoluteString) {
                DispatchQueue.global().async {
                    let result = self.generateResult(resource: resource, data: data, response: nil, error: nil)
                    DispatchQueue.main.async {
                        completion(result.0, result.1)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(Result(error: GiraffeError.invalidRequest), nil)
                }
            }
        case .cacheThenReload:
            if let data = configuration.newCache.data(forKey: url.absoluteString) {
                DispatchQueue.global().async {
                    let result = self.generateResult(resource: resource, data: data, response: nil, error: nil)
                    DispatchQueue.main.async {
                        completion(result.0, result.1)
                    }
                    
                }
            }
        }
        
    }
    
    private func generateResult<A>(resource: Resource<A>, data: Data?, response: URLResponse?, error: Error?) -> (Result<A>, HTTPURLResponse?) {
        let httpResponse = response as? HTTPURLResponse
        let result: Result<A>
        if let httpResponse = httpResponse {
            result = resource.parse(data, httpResponse, error)
        } else {
            result = Result(error: GiraffeError.notHTTP)
        }
        return (result, httpResponse)
    }
}
