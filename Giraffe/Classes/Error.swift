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
    
    case notModified = 304
    
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
    public var success: Bool {
        if rawValue >= 200 && rawValue < 300 {
            return true
        }
        return false
    }
    
    public var failure: Bool {
        return !success
    }
}

public enum GiraffeError: Swift.Error {
    case invalidResponse
    case notHTTP
    case noCacheData
    case notAvailabelForPolling
    case notModified
}

public extension Swift.Error {
    var giraffeError: GiraffeError? {
        let error = self as? GiraffeError
        return error
    }
    
    var isGiraffe: Bool { return (self is GiraffeError) }
    
    var isNoCacheData: Bool {
        guard let ge = giraffeError else { return false }
        return ge == .noCacheData
    }
    
    var isNotHTTP: Bool {
        guard let ge = giraffeError else { return false }
        return ge == .notHTTP
    }
    
    var isInvalidResponse: Bool {
        guard let ge = giraffeError else { return false }
        return ge == .invalidResponse
    }
    
    var isNotAvailabelForPolling: Bool {
        guard let ge = giraffeError else { return false }
        return ge == .notAvailabelForPolling
    }
    
    var isNotModified: Bool {
        guard let ge = giraffeError else { return false }
        return ge == .notModified
    }
}
