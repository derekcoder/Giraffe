//
//  Error.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public enum GiraffeError: Error {
    case notHTTP
    case jsonParsingFailed
    case other
    
    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
}

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
    public var error: GiraffeError? {
        switch self {
        case .ok, .created, .accepted, .noContent, .resetContent: return nil
        case .badRequest: return GiraffeError.badRequest
        case .unauthorized: return GiraffeError.unauthorized
        case .paymentRequired: return GiraffeError.paymentRequired
        case .forbidden: return GiraffeError.forbidden
        case .notFound: return GiraffeError.notFound
        case .methodNotAllowed: return GiraffeError.methodNotAllowed
        case .notAcceptable: return GiraffeError.notAcceptable
        case .proxyAuthenticationRequired: return GiraffeError.proxyAuthenticationRequired
        case .requestTimeout: return GiraffeError.requestTimeout
        case .conflict: return GiraffeError.conflict
        case .internalServerError: return GiraffeError.internalServerError
        case .notImplemented: return GiraffeError.notImplemented
        case .badGateway: return GiraffeError.badGateway
        case .serviceUnavailable: return GiraffeError.serviceUnavailable
        case .gatewayTimeout: return GiraffeError.gatewayTimeout
        case .httpVersionNotSupported: return GiraffeError.httpVersionNotSupported
        }
    }
}
