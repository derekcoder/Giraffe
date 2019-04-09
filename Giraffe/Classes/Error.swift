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
    
    var isNotModified: Bool {
        guard let ge = giraffeError else { return false }
        return ge == .notModified
    }    
}

////////////////////

public enum APIError: Error {
    case requestTimeout               // 没有得到响应
    case apiFailed(APIResponseError)  // 得到响应，但是 HTTP Status Code 非 200
    case invalidResponse              // 得到响应且 Status Code 为 200，但是无法正确解析数据
    case apiResultFailed(Error)       // 请求和响应都正常，但是 API 的结果是失败的
}

public extension APIError {
    enum APIResponseError {
        case notModified       // 304
        case permissionDenied  // 403
        case entryNotFound     // 404
        case serverDied        // 500
        case others(statusCode: Int)
    }
}

public extension Int {
    var responseError: APIError.APIResponseError {
        switch self {
        case 304: return .notModified
        case 403: return .permissionDenied
        case 404: return .entryNotFound
        case 500: return .serverDied
        default: return .others(statusCode: self)
        }
    }
    
    var successStatus: Bool {
        return self >= 200 && self < 300
    }
    
    var failureStatus: Bool {
        return !successStatus
    }
}
