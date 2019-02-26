//
//  Giraffe.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public struct Giraffe {
    public struct Configuration {
        public var authenticationToken: String? = nil
        public let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 40 * 1024 * 1024, diskPath: "com.derekcoder.urlcache")
        public var debugEnabled = false
        public var headers: [HTTPRequestHeaderField: String]? = nil
        
        public var conditionalRequestManager = ConditionalRequestManager()
        
        public static var `default`: Configuration {
            return Configuration()
        }
        
        public init() { }
    }
    
    public enum LoadStrategy {
        case onlyReload
        case onlyCache
        case cacheThenReload
        case cacheOrReload
    }
    
    public enum CacheExpiration {
        case none
        case seconds(TimeInterval)
        case hours(Int)
        case days(Int)
        case date(Date)
        
        func estimatedExpirationDateSince(_ date: Date) -> Date? {
            switch self {
            case .none: return nil
            case .seconds(let seconds): return date.addingTimeInterval(-seconds)
            case .hours(let hours): return date.addingTimeInterval(-TimeInterval(60 * 60 * hours))
            case .days(let days): return date.addingTimeInterval(-TimeInterval(24 * 60 * 60 * days))
            case .date(let ref): return ref
            }
        }
        
        func isExpired(for date: Date) -> Bool {
            guard let miniExpirationDate = estimatedExpirationDateSince(Date()) else { return false }
            return date < miniExpirationDate
        }
    }
    
    public struct Option {
        public var strategy: Giraffe.LoadStrategy
        public var expiration: Giraffe.CacheExpiration
        
        public init(strategy: Giraffe.LoadStrategy = .onlyReload, expiration: Giraffe.CacheExpiration = .none) {
            self.strategy = strategy
            self.expiration = expiration
        }
    }
}

public enum CallbackQueue {
    case mainAsync
    case globalAsync
    
    public func execute(_ block: @escaping () -> ()) {
        switch self {
        case .mainAsync: DispatchQueue.main.async { block() }
        case .globalAsync: DispatchQueue.global().async { block() }
        }
    }
}

public typealias JSONDictionary = [String: Any]

public extension URL {
    mutating func appendQueryItems(_ items: [String: String]) {
        self = appendingQueryItems(items)
    }
    
    func appendingQueryItems(_ items: [String: String]) -> URL {
        guard var urlComps = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return self }
        
        let currentItems = urlComps.queryItems ?? []
        let filteredItems = currentItems.filter { !items.keys.contains($0.name) }
        let addingItems = items.map { URLQueryItem(name: $0, value: $1) }
        urlComps.queryItems = filteredItems + addingItems
        
        return urlComps.url ?? self
    }
}

public extension String {
    var escapedForURLQuery: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
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
