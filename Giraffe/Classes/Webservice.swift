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
    public init<A>(resource: Resource<A>, authenticationToken: String? = nil) {
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
        
    public convenience init(configuration: GiraffeConfiguration = GiraffeConfiguration.default) {
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        let session = URLSession(configuration: config)
        self.init(session: session, configuration: configuration)
    }
    
    public init(session: URLSession, configuration: GiraffeConfiguration = GiraffeConfiguration.default) {
        self.session = session
        self.configuration = configuration
    }
}

extension Webservice {
    public func load<A>(_ resource: Resource<A>, cachePolicy: GiraffeCachePolicy = .reloadIgnoringCacheData, completion: @escaping (Result<A>) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: configuration.authenticationToken)
        
        switch cachePolicy {
        case .reloadIgnoringCacheData:
            sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
        case .reloadCacheDataElseLoad:
            DispatchQueue.global().async {
                if let cachedResponse = self.loadCachedResponse(for: resource) {
                    DispatchQueue.main.async {
                        completion(cachedResponse.result)
                    }
                    if !self.configuration.dontRequestWhenTimeTooShort ||
                        Date().timeIntervalSince(cachedResponse.createdDate) > self.configuration.timeIntervalForDontRequest {
                        self.sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
                    }
                } else {
                    self.sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
                }
            }
        case .returnCacheDataDontLoad:
            DispatchQueue.global().async {
                guard let cachedResponse = self.loadCachedResponse(for: resource) else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.noCacheData))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(cachedResponse.result)
                }
            }
        }
    }
    
    public func load<A>(_ resource: Resource<A>, cachePolicy: GiraffeCachePolicy = .reloadIgnoringCacheData, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: configuration.authenticationToken)
        
        switch cachePolicy {
        case .reloadIgnoringCacheData:
            sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
        case .reloadCacheDataElseLoad:
            DispatchQueue.global().async {
                if let cachedResponse = self.loadCachedResponse(for: resource) {
                    DispatchQueue.main.async {
                        completion(cachedResponse.result, cachedResponse.httpResponse)
                    }
                    if !self.configuration.dontRequestWhenTimeTooShort ||
                        Date().timeIntervalSince(cachedResponse.createdDate) > self.configuration.timeIntervalForDontRequest {
                        self.sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
                    }
                } else {
                    self.sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
                }
            }
        case .returnCacheDataDontLoad:
            DispatchQueue.global().async {
                guard let cachedResponse = self.loadCachedResponse(for: resource) else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.noCacheData), nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(cachedResponse.result, cachedResponse.httpResponse)
                }
            }
        }
    }
    
    private func sendRequest<A>(_ request: URLRequest, cachePolicy: GiraffeCachePolicy, resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            
            let cachedResponse = CachedResponse(resource: resource, response: response, data: data, createdDate: Date())
            if cachePolicy.needSave {
                self.saveCachedResponse(cachedResponse)
            }
            
            DispatchQueue.global().async {
                let result = cachedResponse.result
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }) .resume()
    }
    
    private func sendRequest<A>(_ request: URLRequest, cachePolicy: GiraffeCachePolicy, resource: Resource<A>, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            
            let cachedResponse = CachedResponse(resource: resource, response: response, data: data, createdDate: Date())
            if cachePolicy.needSave {
                self.saveCachedResponse(cachedResponse)
            }
            
            DispatchQueue.global().async {
                let result = cachedResponse.result
                let httpResponse = cachedResponse.httpResponse
                DispatchQueue.main.async {
                    completion(result, httpResponse)
                }
            }
        }) .resume()
    }
}
