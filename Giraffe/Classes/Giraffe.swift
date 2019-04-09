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
        
        var httpCacheManager = HTTPCacheManager()
        
        public static var `default`: Configuration {
            return Configuration()
        }
        
        public init() { }
    }
}

public extension Giraffe {
    struct Option {
        public var strategy: Giraffe.LoadStrategy
        public var expiration: Giraffe.CacheExpiration
        public var httpCacheEnabled: Bool
        
        public init(strategy: Giraffe.LoadStrategy = .onlyReload, expiration: Giraffe.CacheExpiration = .none, httpCacheEnabled: Bool = false) {
            self.strategy = strategy
            self.expiration = expiration
            self.httpCacheEnabled = httpCacheEnabled
        }
    }
}

public extension Giraffe {
    enum LoadStrategy {
        case onlyReload
        case onlyCache
        case cacheThenReload
        case cacheOrReload
    }
}

public extension Giraffe {
    enum CacheExpiration {
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
}

public typealias JSONDictionary = [String: Any]
