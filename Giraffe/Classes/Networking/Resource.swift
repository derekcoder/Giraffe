//
//  Resource.swift
//  Giraffe
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any]

public enum HttpMethod<A> {
    case get
    case post(data: A)
    case put(data: A)
    case patch(data: A)
    case delete
}

public extension HttpMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        }
    }
    
    func map<B>(f: (A) throws -> B) rethrows -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let data): return .post(data: try f(data))
        case .put(let data): return .put(data: try f(data))
        case .patch(let data): return .patch(data: try f(data))
        case .delete: return .delete
        }
    }
}

public struct Resource<A> {
    public var url: URL
    public var method: HttpMethod<Data?> = .get
    public var parse: (Data?) -> Result<A, APIError>
    public var headers: [HTTPRequestHeaderField: String]? = nil
    public var timeoutInterval: TimeInterval = 20.0 // in seconds, default: 60 seconds
}

public extension Resource {
    init(url: URL, method: HttpMethod<Data?> = .get, headers: [HTTPRequestHeaderField: String]? = nil, parse: @escaping (Data?) -> Result<A, APIError>) {
        self.url = url
        self.method = method
        self.headers = headers
        self.parse = parse
    }
    
    init(url: URL, method: HttpMethod<Data?> = .get, headers: [HTTPRequestHeaderField: String]? = nil, parseJSON: @escaping (Any) -> Result<A, APIError>) {
        self.url = url
        self.method = method
        self.headers = headers
        self.parse = { data in
            guard let data = data,
                let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
                return Result.failure(.invalidResponse)
            }
            return parseJSON(obj)
        }
    }

    init(url: URL, jsonMethod: HttpMethod<Any>, headers: [HTTPRequestHeaderField: String]? = nil, parse: @escaping (Data?) -> Result<A, APIError>) {
        self.url = url
        self.parse = parse
        self.headers = headers
        self.method = jsonMethod.map { jsonObject in
            try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
        }
    }
    
    init(url: URL, jsonMethod: HttpMethod<Any>, headers: [HTTPRequestHeaderField: String]? = nil, parseJSON: @escaping (Any) -> Result<A, APIError>) {
        self.url = url
        self.headers = headers
        self.method = jsonMethod.map { jsonObject in
            try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
        }
        self.parse = { data in
            guard let data = data,
                let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    return Result.failure(.invalidResponse)
            }
            return parseJSON(obj)
        }
    }
}
