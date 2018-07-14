//
//  Resource.swift
//  SwiftDevHints
//
//  Created by Derek on 2/1/18.
//  Copyright © 2018 ZHOU DENGFENG DEREK. All rights reserved.
//

// Referenced from https://talk.objc.io/

import Foundation

public enum HttpMethod<A> {
    case get
    case post(data: A)
    case put(data: A)
    case delete
    
    public var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
    
    public func map<B>(f: (A) throws -> B) rethrows -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let data): return .post(data: try f(data))
        case .put(let data): return .put(data: try f(data))
        case .delete: return .delete
        }
    }
}

public struct Resource<A> {
    public var url: URL
    public var method: HttpMethod<Data?> = .get
    public var parse: (Data, HTTPURLResponse) -> Result<A>
    public var headers: [String: String]? = nil
    public var timeoutInterval: TimeInterval = 20.0 // in seconds, default: 60 seconds
    
    public init(url: URL, method: HttpMethod<Data?> = .get, headers: [String: String]? = nil, parse: @escaping (Data, HTTPURLResponse) -> Result<A>) {
        self.url = url
        self.parse = parse
        self.method = method
        self.headers = headers
    }
}

extension Resource {
    public init(url: URL, method: HttpMethod<Data?> = .get , parseJSON: @escaping (Any, HTTPURLResponse) -> Result<A>) {
        self.url = url
        self.method = method
        self.parse = { data, response in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) else {
                return Result.error(WebserviceError.jsonParsingFailed)
            }
            return parseJSON(json, response)
        }
    }
    
    public init(url: URL, jsonMethod: HttpMethod<Any>, parse: @escaping (Data, HTTPURLResponse) -> Result<A>) {
        self.url = url
        self.parse = parse
        self.method = jsonMethod.map { jsonObject in
            try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
        }
    }
    
    public init(url: URL, jsonMethod: HttpMethod<Any>, parseJSON: @escaping (Any, HTTPURLResponse) -> Result<A>) {
        self.url = url
        self.method = jsonMethod.map { jsonObject in
            try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
        }
        self.parse = { data, response in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) else {
                return Result.error(WebserviceError.jsonParsingFailed)
            }
            return parseJSON(json, response)
        }
    }
}
