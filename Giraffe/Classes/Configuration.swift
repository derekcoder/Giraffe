//
//  Configuration.swift
//  Giraffe
//
//  Created by Derek on 10/12/18.
//

import Foundation

public class GiraffeConfiguration {
    public var authenticationToken: String?
    public var dontRequestWhenTimeTooShort: Bool // only valid for get http method
    public var timeIntervalForDontRequest: TimeInterval
    public let cache = URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 0, diskPath: nil)
    
    public static var `default`: GiraffeConfiguration {
        return GiraffeConfiguration()
    }
    
    public init() {
        self.authenticationToken = nil
        self.dontRequestWhenTimeTooShort = false
        self.timeIntervalForDontRequest = 10
    }
}
