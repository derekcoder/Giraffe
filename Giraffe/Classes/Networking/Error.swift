//
//  Error.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public enum APIError: Error {
    case requestTimeout      // No response from server
    case apiFailed(Int)      // Got response, but HTTP status code is not 2xx
    case invalidResponse     // Got response and HTTP status code is also 2xx, but cannot parse data correctly
}

extension APIError: Equatable {
    public static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.requestTimeout, .requestTimeout): return true
        case (.apiFailed(let lv), .apiFailed(let rv)): return lv == rv
        case (.invalidResponse, .invalidResponse): return true
        default: return false
        }
    }
}
