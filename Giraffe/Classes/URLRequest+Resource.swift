//
//  URLRequest+Resource.swift
//  Giraffe
//
//  Created by derekcoder on 27/12/18.
//

import Foundation

public extension URLRequest {
    init<A>(resource: Resource<A>, authenticationToken: String? = nil, headers: [HTTPRequestHeaderField: String]? = nil) {
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
        
        headers?.forEach { setHeaderValue($1, for: $0) }
        resource.headers?.forEach { setHeaderValue($1, for: $0) }
        
        if headerValue(for: .contentType) == nil {
            setHeaderValue(MediaType.appJSON.rawValue, for: .contentType)
        }
        if headerValue(for: .accept) == nil {
            setHeaderValue(MediaType.appJSON.rawValue, for: .accept)
        }
    }
    
    mutating func setHeaderValue(_ value: String?, for field: HTTPRequestHeaderField) {
        setValue(value, forHTTPHeaderField: field.key)
    }
    
    func headerValue(for field: HTTPRequestHeaderField) -> String? {
        return value(forHTTPHeaderField: field.key)
    }
}
