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
    public var configuration: Giraffe.Configuration
        
    public init(configuration: Giraffe.Configuration = Giraffe.Configuration.default) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = nil
        self.session = URLSession(configuration: sessionConfig)
        self.configuration = configuration
    }

    public func removeHTTPCache<A>(for resource: Resource<A>) {
        configuration.httpCacheManager.removeHTTPCache(for: resource.url.absoluteString)
    }
    
    public func load<A>(_ resource: Resource<A>, option: Giraffe.Option = Giraffe.Option(), completion: @escaping (Result<A>) -> ()) {
        load(resource, option: option) { result, _ in
            completion(result)
        }
    }
    
    public func load<A>(_ resource: Resource<A>, option: Giraffe.Option = Giraffe.Option(), completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        guard case .get = resource.method else {
            sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
            return
        }
        
        switch option.strategy {
        case .onlyReload: sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
        case .onlyCache:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: option.expiration) {
                    let result = cachedResponse.result
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(result, cachedResponse.httpResponse)
                    }
                } else {
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("no cache data", for: resource)
                        completion(Result(error: GiraffeError.noCacheData), nil)
                    }
                }
            }
        case .cacheThenReload:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: option.expiration) {
                    let result = cachedResponse.result
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(result, cachedResponse.httpResponse)
                        self.sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
                    }
                } else {
                    self.printDebugMessage("no cache data", for: resource)
                    CallbackQueue.mainAsync.execute {
//                        completion(Result(error: GiraffeError.noCacheData), nil)
                        self.sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
                    }
                }
            }
        case .cacheOrReload:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: option.expiration) {
                    let result = cachedResponse.result
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(result, cachedResponse.httpResponse)
                    }
                } else {
                    self.printDebugMessage("no cache data", for: resource)
                    CallbackQueue.mainAsync.execute {
                        self.sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
                    }
                }
            }
        }
    }
        
    private func sendRequest<A>(for resource: Resource<A>, httpCacheEnabled: Bool, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        var request = URLRequest(resource: resource, authenticationToken: configuration.authenticationToken, headers: configuration.headers)
        
        if httpCacheEnabled, let httpCache = configuration.httpCacheManager.httpCache(for: resource.url.absoluteString) {
            switch httpCache {
            case .eTag(let eTag): request.setHeaderValue(eTag, for: .ifNoneMatch)
            case .lastModified(let lastModified): request.setHeaderValue(lastModified, for: .ifModifiedSince)
            case let .both(eTag, lastModified):
                request.setHeaderValue(eTag, for: .ifNoneMatch)
                request.setHeaderValue(lastModified, for: .ifModifiedSince)
            }
        }
        
        printDebugMessage("sending request", for: resource)
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            CallbackQueue.globalAsync.execute {
                let cachedResponse = CachedResponse(resource: resource, response: response, data: data)
                
                if case .get = resource.method {
                    if cachedResponse.isSuccess {
                        self.printDebugMessage("saving data into cache", for: resource)
                        self.saveCachedResponse(cachedResponse)
                    }
                    
                    if httpCacheEnabled, let httpURLResponse = cachedResponse.httpResponse {
                        self.configuration.httpCacheManager.setHTTPCache(urlString: resource.url.absoluteString,
                                                                          response: httpURLResponse)
                        
                        if httpURLResponse.statusCode == HTTPStatus.notModified.rawValue {
                            CallbackQueue.mainAsync.execute {
                                completion(Result(error: GiraffeError.notModified), cachedResponse.httpResponse)
                            }
                            return
                        }
                    }
                }
                
                let result = resource.parse(data: data, response: response, error: error, isCached: false)
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
