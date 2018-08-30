//
//  Giraffe.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public typealias JSONDictionary = [String: Any]

extension URL {
    public mutating func encode(parameters: JSONDictionary) {
        self = encoded(parameters: parameters)
    }
    
    public func encoded(parameters: JSONDictionary) -> URL {
        let query = parameters.query()
        
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard !parameters.isEmpty else { return self }
        
        let percentEncodedQuery = urlComponents.percentEncodedQuery.map { $0 + "&" } ?? ""
        urlComponents.percentEncodedQuery = percentEncodedQuery + query
        guard let url = urlComponents.url else { return self }
        return url
    }
}

public enum BoolEncoding {
    case numberic, literal
    
    func encode(value: Bool) -> String {
        switch self {
        case .numberic: return value ? "1" : "0"
        case .literal: return value ? "true" : "false"
        }
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension Dictionary where Key == String {
    func query(boolEncoding: BoolEncoding = .numberic) -> String {
        
        func queryComponent(key: String, value: Any) -> (String, String)? {
            if let value = value as? NSNumber {
                if value.isBool {
                    return (key, boolEncoding.encode(value: value.boolValue))
                } else {
                    return (key, "\(value)")
                }
            } else if let value = value as? Bool {
                return (key, boolEncoding.encode(value: value))
            } else {
                return (key, "\(value)")
            }
        }
        
        let components = self.compactMap { queryComponent(key: $0, value: $1) }
        let result = components.map { "\($0)=\($1)"}.joined(separator: "&")
        return result
    }
}
