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
    
    public func load<A>(_ resource: Resource<A>, option: Giraffe.Option = Giraffe.Option(), completion: @escaping (Response<A>) -> ()) {
        guard case .get = resource.method else {
            sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
            return
        }
        /*
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
        }*/
    }
        
    private func sendRequest<A>(for resource: Resource<A>, httpCacheEnabled: Bool, completion: @escaping (Response<A>) -> ()) {
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
                guard let httpResponse = response as? HTTPURLResponse else {
                    let resultResponse = Response<A>(data: data,
                                                     error: error,
                                                     httpResponse: nil,
                                                     result: .failure(.notHTTPURLResponse),
                                                     isCached: false)
                    CallbackQueue.mainAsync.execute {
                        completion(resultResponse)
                    }
                    return
                }
                
                let statusCode = httpResponse.statusCode
                if let error = error, statusCode.failureStatus {
                    var resultResponse = Response<A>(data: data,
                                                     error: error,
                                                     httpResponse: httpResponse,
                                                     result: .failure(.apiFailed(statusCode.responseError)),
                                                     isCached: false)

                    if error._code == NSURLErrorTimedOut {
                        resultResponse.result = .failure(.requestTimeout)
                    }
                    CallbackQueue.mainAsync.execute {
                        completion(resultResponse)
                    }
                } else {
                    
                }
                
                if case .get = resource.method {
                    let cachedResponse = CachedResponse(resource: resource, response: response, data: data)

                    // Local Cache
                    if cachedResponse.isSuccess {
                        self.printDebugMessage("saving data into cache", for: resource)
                        self.saveCachedResponse(cachedResponse)
                    }
                    
                    // HTTP Cache
                    if httpCacheEnabled, let httpURLResponse = cachedResponse.httpResponse {
                        self.configuration.httpCacheManager.setHTTPCache(urlString: resource.url.absoluteString,
                                                                          response: httpURLResponse)
                    }
                }
                
                let result = resource.parse(data: data, response: response, error: error, isCached: false)
                let response = Response<A>(result: result,
                                           data: data,
                                           httpResponse: httpResponse,
                                           isCached: false)
                CallbackQueue.mainAsync.execute {
                    self.printDebugMessage("loaded data from request", for: resource)
                    completion(response)
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
