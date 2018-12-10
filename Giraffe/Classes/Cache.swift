//
//  Cache.swift
//  Giraffe
//
//  Created by Derek on 10/12/18.
//

import Foundation

public enum GiraffeCachePolicy {
    case reloadIgnoringCacheData /* The URL load should be loaded only from the originating source. */
    case reloadCacheDataElseLoad /* Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data. */
    case returnCacheDataDontLoad /* Use existing cache data, regardless or age or expiration date, and fail if no cached data is available. */
    
    var needSave: Bool {
        return true
    }
}

struct CachedResponse<A> {
    let resource: Resource<A>
    let response: URLResponse?
    let data: Data?
    let createdDate: Date
}

extension CachedResponse {
    public var request: URLRequest {
        return URLRequest(resource: resource)
    }
    
    init(resource: Resource<A>, cachedURLResponse: CachedURLResponse) {
        self.resource = resource
        self.response = cachedURLResponse.response
        self.data = cachedURLResponse.data
        
        let createdDate = cachedURLResponse.userInfo?["created_date"] as? Date
        self.createdDate = createdDate ?? Date()
    }
    
    var cachedURLResponse: CachedURLResponse? {
        guard let response = response, let data = data else { return nil }
        let cachedURLResponse = CachedURLResponse(response: response, data: data, userInfo: ["created_date": createdDate], storagePolicy: .allowed)
        return cachedURLResponse
    }
    
    var result: Result<A> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return Result(error: GiraffeError.notHTTP)
        }
        let result = resource.parse(data, httpResponse, nil)
        return result
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
    
    func loadCachedResponse<A>(for resource: Resource<A>) -> CachedResponse<A>? {
        let request = URLRequest(resource: resource)
        guard let cachedURLResponse = configuration.cache.cachedResponse(for: request) else { return nil }
        let cachedResponse = CachedResponse(resource: resource, cachedURLResponse: cachedURLResponse)
        return cachedResponse
    }
}
