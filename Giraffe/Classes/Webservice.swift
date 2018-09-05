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
    public var session: URLSession
    
    public convenience init() {
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        let session = URLSession(configuration: config)
        self.init(session: session)
    }
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: authenticationToken)
        session.dataTask(with: request, completionHandler: { data, response, _ in
            DispatchQueue.global().async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.notHTTP))
                    }
                    return
                }
                guard httpResponse.statusCode != HTTPStatus.unauthorized.rawValue else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.unauthorized))
                    }
                    return
                }
                guard let result = data.map({ resource.parse($0, httpResponse) }) else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.other))
                    }
                    return
                }
                
                DispatchQueue.main.async { completion(result) }
            }
        }) .resume()
    }
    
    public func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>, HTTPURLResponse?) -> ()) {
        let request = URLRequest(resource: resource, authenticationToken: authenticationToken)
        session.dataTask(with: request, completionHandler: { data, response, _ in
            DispatchQueue.global().async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.notHTTP), nil)
                    }
                    return
                }
                guard httpResponse.statusCode != HTTPStatus.unauthorized.rawValue else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.unauthorized), httpResponse)
                    }
                    return
                }
                guard let result = data.map({ resource.parse($0, httpResponse) }) else {
                    DispatchQueue.main.async {
                        completion(Result(error: GiraffeError.other), httpResponse)
                    }
                    return
                }
                
                DispatchQueue.main.async { completion(result, httpResponse) }
            }
        }) .resume()
    }
}
