//
//  Webservice.swift
//  SwiftDevHints
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

// Referenced from https://talk.objc.io/

import Foundation

public typealias JSONDictionary = [String: Any]

public enum Result<A> {
    case success(A)
    case error(Error)
}

extension Result {
    public init(_ value: A?, or error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error)
        }
    }
    
    public init(error: Error) {
        self = .error(error)
    }
    
    public init(_ error: Error) {
        self = .error(error)
    }
    
    public init(value: A) {
        self = .success(value)
    }
    
    public init(_ value: A) {
        self = .success(value)
    }
    
    public var value: A? {
        guard case .success(let v) = self else { return nil }
        return v
    }
    
    public func map<B>(_ transform: (A) throws -> B) rethrows -> Result<B> {
        switch self {
        case .success(let value):
            return .success(try transform(value))
        case .error(let error):
            return .error(error)
        }
    }
}

public enum WebserviceError: Error {
    case notAuthenticated
    case notHTTP
    case jsonParsingFailed
    case other
}

extension URLRequest {
    public init<A>(resource: Resource<A>, authenticationToken: String? = nil) {
        self.init(url: resource.url, timeoutInterval: resource.timeoutInterval)
        
        httpMethod = resource.method.method
        if case let .post(data) = resource.method {
            if let data = data {
                httpBody = data
            } else {
                setValue("0", forHTTPHeaderField: "Content-Length")
            }
        } else if case let .put(data) = resource.method {
            if let data = data {
                httpBody = data
            } else {
                setValue("0", forHTTPHeaderField: "Content-Length")
            }
        } else if case let .patch(data) = resource.method {
            if let data = data {
                httpBody = data
            } else {
                setValue("0", forHTTPHeaderField: "Content-Length")
            }
        }
        
        if let token = authenticationToken {
            setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        if let headers = resource.headers {
            headers.forEach { setValue($1, forHTTPHeaderField: $0) }
        } else {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
            setValue("application/json", forHTTPHeaderField: "Accept")
        }
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
                    DispatchQueue.main.async { completion(Result.error(WebserviceError.notHTTP)) }
                    return
                }
                guard httpResponse.statusCode != 401 else {
                    DispatchQueue.main.async { completion(Result.error(WebserviceError.notAuthenticated)) }
                    return
                }
                
                guard let result = data.map({ resource.parse($0, httpResponse) }) else {
                    DispatchQueue.main.async { completion(Result.error(WebserviceError.other)) }
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
                    DispatchQueue.main.async { completion(Result.error(WebserviceError.notHTTP), nil) }
                    return
                }
                guard httpResponse.statusCode != 401 else {
                    DispatchQueue.main.async { completion(Result.error(WebserviceError.notAuthenticated), httpResponse) }
                    return
                }
                
                guard let result = data.map({ resource.parse($0, httpResponse) }) else {
                    DispatchQueue.main.async { completion(Result.error(WebserviceError.other), httpResponse) }
                    return
                }
                
                DispatchQueue.main.async { completion(result, httpResponse) }
            }
        }) .resume()
    }
}
