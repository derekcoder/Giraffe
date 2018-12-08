//
//  Error.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public enum HTTPStatus: Int {
    case ok = 200
    
    case created = 201
    case accepted = 202
    case noContent = 204
    case resetContent = 205
    
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
}

extension HTTPStatus {
    var success: Bool {
        if rawValue >= 200 && rawValue < 300 {
            return true
        }
        return false
    }
    
    var failure: Bool {
        return !success
    }
}

public enum GiraffeError: Swift.Error {
    case invalidResponse
    case notHTTP
}
