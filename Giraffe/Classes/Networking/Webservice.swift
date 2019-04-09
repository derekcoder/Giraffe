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
    
    public func load<A>(_ resource: Resource<A>,
                        option: Giraffe.Option = Giraffe.Option(),
                        completion: @escaping (ResultResponse<A>) -> ()) {
        
        // Check if the current request is a GET request.
        guard case .get = resource.method else {
            // If not, send the API request directly.
            sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
            return
        }

        // If it is, check the caching strategy.
        switch option.strategy {
        case .onlyReload: sendRequest(for: resource, httpCacheEnabled: option.httpCacheEnabled, completion: completion)
        case .onlyCache:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: option.expiration) {
                    let result = cachedResponse.result
                    let resultResponse = ResultResponse(data: cachedResponse.data,
                                                        error: nil,
                                                        httpResponse: cachedResponse.httpResponse,
                                                        result: result,
                                                        isCached: true)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(resultResponse)
                    }
                } else {
                    let result: Result<A, APIError> = .failure(.apiResultFailed(CacheError.noCacheData))
                    let resultResponse = ResultResponse<A>(data: nil,
                                                           error: nil,
                                                           httpResponse: nil,
                                                           result: result,
                                                           isCached: true)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("no cache data", for: resource)
                        completion(resultResponse)
                    }
                }
            }
        case .cacheThenReload:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource, expiration: option.expiration) {
                    let result = cachedResponse.result
                    let resultResponse = ResultResponse(data: cachedResponse.data,
                                                        error: nil,
                                                        httpResponse: cachedResponse.httpResponse,
                                                        result: result,
                                                        isCached: true)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(resultResponse)
                        self.sendRequest(for: resource,
                                         httpCacheEnabled: option.httpCacheEnabled,
                                         completion: completion)
                    }
                } else {
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("no cache data", for: resource)
                        self.sendRequest(for: resource,
                                         httpCacheEnabled: option.httpCacheEnabled,
                                         completion: completion)
                    }
                }
            }
        case .cacheOrReload:
            CallbackQueue.globalAsync.execute {
                self.printDebugMessage("loading cached data", for: resource)
                if let cachedResponse = self.loadCachedResponse(for: resource,
                                                                expiration: option.expiration) {
                    let result = cachedResponse.result
                    let resultResponse = ResultResponse(data: cachedResponse.data,
                                                        error: nil,
                                                        httpResponse: cachedResponse.httpResponse,
                                                        result: result,
                                                        isCached: true)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded cached data", for: resource)
                        completion(resultResponse)
                    }
                } else {
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("no cache data", for: resource)
                        self.sendRequest(for: resource,
                                         httpCacheEnabled: option.httpCacheEnabled,
                                         completion: completion)
                    }
                }
            }
        }
    }
        
    private func sendRequest<A>(for resource: Resource<A>,
                                httpCacheEnabled: Bool,
                                completion: @escaping (ResultResponse<A>) -> ()) {
        
        var request = URLRequest(resource: resource,
                                 authenticationToken: configuration.authenticationToken,
                                 headers: configuration.headers)
        
        if httpCacheEnabled,
            let httpCache = configuration.httpCacheManager.httpCache(for: resource.url.absoluteString) {
            
            switch httpCache {
            case .eTag(let eTag):
                request.setHeaderValue(eTag, for: .ifNoneMatch)
            case .lastModified(let lastModified):
                request.setHeaderValue(lastModified, for: .ifModifiedSince)
            case let .both(eTag, lastModified):
                request.setHeaderValue(eTag, for: .ifNoneMatch)
                request.setHeaderValue(lastModified, for: .ifModifiedSince)
            }
        }
        
        printDebugMessage("sending request", for: resource)
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            CallbackQueue.globalAsync.execute {
                
                // Check if the request times out.
                guard error?._code != NSURLErrorTimedOut else {
                    // If it is, return response with .requestTimeout error directly.
                    let resultResponse = ResultResponse<A>(data: data,
                                                           error: error,
                                                           httpResponse: nil,
                                                           result: .failure(.requestTimeout),
                                                           isCached: false)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("failed to load data: \(resultResponse.result)", for: resource)
                        completion(resultResponse)
                    }
                    return
                }
                
                // Check if response is HTTPURLResponse.
                guard let httpResponse = response as? HTTPURLResponse else {
                    // If not, return response with .invalidResponse error directly.
                    let resultResponse = ResultResponse<A>(data: data,
                                                           error: error,
                                                           httpResponse: nil,
                                                           result: .failure(.invalidResponse),
                                                           isCached: false)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("failed to load data: not http url response", for: resource)
                        completion(resultResponse)
                    }
                    return
                }
                
                // Check if the current request is successful.
                let statusCode = httpResponse.statusCode
                if statusCode.failureStatus { // status code not in 200..<300
                    // If not, return response with .apiFailed error.
                    let resultResponse = ResultResponse<A>(data: data,
                                                           error: error,
                                                           httpResponse: httpResponse,
                                                           result: .failure(.apiFailed(statusCode.responseError)),
                                                           isCached: false)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("failed to load data: \(resultResponse.result)", for: resource)
                        completion(resultResponse)
                    }
                } else { // status code in 200..<300
                    // Save to cache
                    if case .get = resource.method {
                        let cachedResponse = CachedResponse(resource: resource,
                                                            httpResponse: httpResponse,
                                                            data: data)
                        
                        // local cache
                        self.printDebugMessage("saving data into cache", for: resource)
                        self.saveCachedResponse(cachedResponse)
                        
                        // http cache
                        if httpCacheEnabled {
                            self.configuration.httpCacheManager.setHTTPCache(urlString: resource.url.absoluteString,
                                                                            response: httpResponse)
                        }
                    }

                    // Parse data to get result, then return response
                    // This step may produce .apiResultFailed error in resource parse closure
                    let resourceResponse = ResourceResponse(data: data,
                                                            httpResponse: httpResponse,
                                                            isCached: false)
                    let result = resource.parse(resourceResponse)
                    let resultResponse = ResultResponse(data: data,
                                                        error: error,
                                                        httpResponse: httpResponse,
                                                        result: result,
                                                        isCached: false)
                    CallbackQueue.mainAsync.execute {
                        self.printDebugMessage("loaded data from request", for: resource)
                        completion(resultResponse)
                    }
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
