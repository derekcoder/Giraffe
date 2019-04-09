//
//  ConditionalRequestManager.swift
//  Giraffe
//
//  Created by derekcoder on 26/2/19.
//

import Foundation

enum HTTPCache {
    case eTag(String)
    case lastModified(String)
    case both(eTag: String, lastModified: String)
}

class HTTPCacheManager {
    private var requests: [String: HTTPCache] = [:]
    
    func setHTTPCache(urlString: String, response: HTTPURLResponse) {
        let headers = response.allHeaderFields
        
        guard response.statusCode == 200 else { return }
        
        let eTag = headers["Etag"] as? String
        let lastModified = headers["Last-Modified"] as? String
        
        var httpCache: HTTPCache?
        if let eTag = eTag, let lastModified = lastModified {
            httpCache = .both(eTag: eTag, lastModified: lastModified)
        } else if let eTag = eTag {
            httpCache = .eTag(eTag)
        } else if let lastModified = lastModified {
            httpCache = .lastModified(lastModified)
        }
        
        if let cache = httpCache {
            requests[urlString] = cache
        } else {
            requests.removeValue(forKey: urlString)
        }
    }
    
    func httpCache(for urlString: String) -> HTTPCache? {
        return requests[urlString]
    }
    
    func removeHTTPCache(for urlString: String) {
        requests.removeValue(forKey: urlString)
    }
}
