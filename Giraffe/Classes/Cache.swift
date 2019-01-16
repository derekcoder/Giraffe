//
//  Cache.swift
//  Giraffe
//
//  Created by Derek on 12/12/18.
//

import Foundation

struct CachedResponse<A> {
    let resource: Resource<A>
    let response: URLResponse?
    let data: Data?
    let createdDate: Date
    var expired: Bool
}

extension CachedResponse {
    init(resource: Resource<A>, response: URLResponse?, data: Data?) {
        self.resource = resource
        self.response = response
        self.data = data
        self.createdDate = Date()
        self.expired = false
    }
    
    var request: URLRequest {
        return URLRequest(resource: resource)
    }
    
    init(resource: Resource<A>, cachedURLResponse: CachedURLResponse) {
        self.resource = resource
        self.response = cachedURLResponse.response
        self.data = cachedURLResponse.data
        
        let createdDate = cachedURLResponse.userInfo?["created_date"] as? Date
        let expired = cachedURLResponse.userInfo?["expired"] as? Bool
        self.createdDate = createdDate ?? Date()
        self.expired = expired ?? false
    }
    
    var cachedURLResponse: CachedURLResponse? {
        guard let response = response, let data = data else { return nil }
        let userInfo: [String: Any] = ["created_date": createdDate, "expired": expired]
        let cachedURLResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: .allowed)
        return cachedURLResponse
    }
    
    var result: Result<A> {
        return resource.parse(data: data, response: response, error: nil, isCached: true)
    }
    
    var httpResponse: HTTPURLResponse? {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        return httpResponse
    }
}

extension Webservice {
    func saveCachedResponse<A>(_ cachedResponse: CachedResponse<A>) {
        guard case .get = cachedResponse.resource.method else { return }
        guard let cachedURLResponse = cachedResponse.cachedURLResponse else { return }
        configuration.cache.storeCachedResponse(cachedURLResponse, for: cachedResponse.request)
    }
    
    func loadCachedResponse<A>(for resource: Resource<A>, expiration: CacheExpiration) -> CachedResponse<A>? {
        let request = URLRequest(resource: resource)
        guard let cachedURLResponse = configuration.cache.cachedResponse(for: request) else { return nil }
        let cachedResponse = CachedResponse(resource: resource, cachedURLResponse: cachedURLResponse)
        guard !cachedResponse.expired && !expiration.isExpired(for: cachedResponse.createdDate) else {
            printDebugMessage("cached data is expired", for: resource)
            return nil
        }
        return cachedResponse
    }
}

public extension Webservice {
    func removeCache<A>(for resource: Resource<A>) {
        printDebugMessage("removed data from cache", for: resource)
        let request = URLRequest(resource: resource)
        if let cachedURLResponse = configuration.cache.cachedResponse(for: request) {
            var cachedResponse = CachedResponse(resource: resource, cachedURLResponse: cachedURLResponse)
            cachedResponse.expired = true
            saveCachedResponse(cachedResponse)
            
            configuration.cache.removeCachedResponse(for: request)
        }        
    }
    
    func removeAllCaches() {
        configuration.cache.removeAllCachedResponses()
    }
}
