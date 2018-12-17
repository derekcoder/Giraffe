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
    public var configuration: Giraffe.Configuration
        
    public init(configuration: Giraffe.Configuration = Giraffe.Configuration.default) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = nil
        self.session = URLSession(configuration: sessionConfig)
        self.configuration = configuration
    }
}

extension Webservice {
    public func load<A>(_ resource: Resource<A>, strategy: Giraffe.Strategy = .onlyReload, expiration: CacheExpiration = .none, completion: @escaping (Result<A>) -> ()) {
        loadDataByStategy(strategy, expiration: expiration, resource: resource) { result, _, _ in
            completion(result)
        }
    }
    
    public func load<A>(_ resource: Resource<A>, strategy: Giraffe.Strategy = .onlyReload, expiration: CacheExpiration = .none, completion: @escaping (Result<A>, Bool) -> ()) {
        loadDataByStategy(strategy, expiration: expiration, resource: resource) { result, _, isFirst in
            completion(result, isFirst)
        }
    }
    
    public func load<A>(_ resource: Resource<A>, strategy: Giraffe.Strategy = .onlyReload, expiration: CacheExpiration = .none, completion: @escaping (Result<A>, HTTPURLResponse?, Bool) -> ()) {
        loadDataByStategy(strategy, expiration: expiration, resource: resource, completion: completion)
    }
    
    private func loadDataByStategy<A>(_ strategy: Giraffe.Strategy, expiration: CacheExpiration = .none, resource: Resource<A>, completion: @escaping (Result<A>, HTTPURLResponse?, Bool) -> ()) {
        guard case .get = resource.method else {
            sendRequest(for: resource, completion: { result, response in
                completion(result, response, true)
            })
            return
        }
        
        switch strategy {
        case .onlyReload: sendRequest(for: resource, completion: { result, response in completion(result, response, true) })
        case .onlyCache:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: expiration) {
                    let result = cachedResponse.result
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(result, cachedResponse.httpResponse, true)
                    }
                } else {
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("no cache data", for: resource)
                        completion(Result(error: GiraffeError.noCacheData), nil, true)
                    }
                }
            }
        case .cacheThenReload:
            DispatchQueue.global().async {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: expiration) {
                    let result = cachedResponse.result
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(result, cachedResponse.httpResponse, true)
                        self.sendRequest(for: resource, completion: { result, response in
                            completion(result, response, false)
                        })
                    }
                } else {
                    self.printDebugMessage("no cache data", for: resource)
                    CallbackQueue.mainAsync.execute {
                        completion(Result(error: GiraffeError.noCacheData), nil, true)
                        self.sendRequest(for: resource, completion: { result, response in
                            completion(result, response, false)
                        })
                    }
                }
            }
        case .cacheOrReload:
            DispatchQueue.global().async {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: expiration) {
                    let result = cachedResponse.result
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(result, cachedResponse.httpResponse, true)
                    }
                } else {
                    self.printDebugMessage("no cache data", for: resource)
                    self.sendRequest(for: resource, completion: { result, response in
                        completion(result, response, true)
                    })
                }
            }
        }
    }
    
    private func sendRequest<A>(for resource: Resource<A>, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        printDebugMessage("sending request", for: resource)
        let request = URLRequest(resource: resource, authenticationToken: configuration.authenticationToken)
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("saving data into cache", for: resource)
                let cachedResponse = CachedResponse(resource: resource, response: response, data: data)
                
                if case .get = resource.method {
                    self.saveCachedResponse(cachedResponse)
                }
                
                let result = cachedResponse.result
                CallbackQueue.mainAsync.execute {
                    self.printDebugMessage("loaded data from request", for: resource)
                    completion(result, cachedResponse.httpResponse)
                }
            }
        }).resume()
    }
}

extension Webservice {
    func printDebugMessage<A>(_ message: String, for resource: Resource<A>) {
        guard configuration.debugEnabled else { return }
        guard case .get = resource.method else { return }
        print("***** Giraffe: \(message) - \(resource.url.absoluteString)")
    }
}
