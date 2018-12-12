//
//  Configuration.swift
//  Giraffe
//
//  Created by Derek on 10/12/18.
//

import Foundation

public class GiraffeConfiguration {
    public var authenticationToken: String?
    public let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 40 * 1024 * 1024, diskPath: "com.derekcoder.urlcache")
    public let newCache = try! Cache()
    
    public static var `default`: GiraffeConfiguration {
        return GiraffeConfiguration()
    }
    
    public init() {
        self.authenticationToken = nil
    }
}
