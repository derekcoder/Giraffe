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
    public var authenticationToken: String?
    public let session: URLSession
    public let cache = URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 0, diskPath: nil)
    
    public enum CachePolicy {
        case reloadIgnoringCacheData /* The URL load should be loaded only from the originating source. */
        case reloadCacheDataElseLoad /* Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data. */
        case returnCacheDataDontLoad /* Use existing cache data, regardless or age or expiration date, and fail if no cached data is available. */
        
        var needSave: Bool {
            switch self {
            case .reloadIgnoringCacheData: return false
            case .reloadCacheDataElseLoad, .returnCacheDataDontLoad: return true
            }
        }
    }
    
    public convenience init() {
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        let session = URLSession(configuration: config)
        self.init(session: session)
    }
    
    public init(session: URLSession) {
        self.session = session
    }
}

extension Webservice {
    func handleResponse<A>(_ response: URLResponse?, data: Data?, error: Error?, for resource: Resource<A>) -> (Result<A>, HTTPURLResponse?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (Result(error: GiraffeError.notHTTP), nil)
        }
        let result = resource.parse(data, httpResponse, error)
        return (result, httpResponse)
    }
    
    func saveResponse<A>(response: URLResponse?, data: Data?, for resource: Resource<A>) {
        guard case .get = resource.method else { return }
        guard let response = response, let data = data else { return }
        
        let request = URLRequest(resource: resource)
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, for: request)
    }
    
    func loadCachedResponse<A>(for resource: Resource<A>) -> (Result<A>, HTTPURLResponse?)? {
        let request = URLRequest(resource: resource)
        guard let cachedResponse = cache.cachedResponse(for: request) else { return nil }
        let result = handleResponse(cachedResponse.response, data: cachedResponse.data, error: nil, for: resource)
        return (result.0, result.1)
    }
}

extension Webservice {
    public func load<A>(_ resource: Resource<A>, cachePolicy: Webservice.CachePolicy = .reloadIgnoringCacheData, completion: @escaping (Result<A>) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: authenticationToken)
        
        switch cachePolicy {
        case .reloadIgnoringCacheData:
            sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
        case .reloadCacheDataElseLoad:
            DispatchQueue.global().async {
                if let result = self.loadCachedResponse(for: resource) {
                    DispatchQueue.main.async {
                        completion(result.0)
                    }
                }
                self.sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
            }
        case .returnCacheDataDontLoad:
            DispatchQueue.global().async {
                guard let result = self.loadCachedResponse(for: resource) else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.noCacheData))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(result.0)
                }
            }
        }
    }
    
    public func load<A>(_ resource: Resource<A>, cachePolicy: Webservice.CachePolicy = .reloadIgnoringCacheData, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: authenticationToken)
        
        switch cachePolicy {
        case .reloadIgnoringCacheData:
            sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
        case .reloadCacheDataElseLoad:
            DispatchQueue.global().async {
                if let result = self.loadCachedResponse(for: resource) {
                    DispatchQueue.main.async {
                        completion(result.0, result.1)
                    }
                }
                self.sendRequest(request, cachePolicy: cachePolicy, resource: resource, completion: completion)
            }
        case .returnCacheDataDontLoad:
            DispatchQueue.global().async {
                guard let result = self.loadCachedResponse(for: resource) else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.noCacheData), nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(result.0, result.1)
                }
            }
        }
    }
    
    private func sendRequest<A>(_ request: URLRequest, cachePolicy: CachePolicy, resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            
            if cachePolicy.needSave {
                self.saveResponse(response: response, data: data, for: resource)
            }
            
            DispatchQueue.global().async {
                let result = self.handleResponse(response, data: data, error: error, for: resource)
                DispatchQueue.main.async {
                    completion(result.0)
                }
            }
        }) .resume()
    }
    
    private func sendRequest<A>(_ request: URLRequest, cachePolicy: CachePolicy, resource: Resource<A>, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            
            if cachePolicy.needSave {
                self.saveResponse(response: response, data: data, for: resource)
            }
            
            DispatchQueue.global().async {
                let result = self.handleResponse(response, data: data, error: error, for: resource)
                DispatchQueue.main.async {
                    completion(result.0, result.1)
                }
            }
        }) .resume()
    }
}
