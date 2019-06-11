//
//  Header.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public enum HTTPRequestHeaderField {
    case accept
    case acceptCharset
    case acceptEncoding
    case acceptLanguage
    case authorization
    case cacheControl
    case contentMD5
    case contentLength
    case contentTransferEncoding
    case contentType
    case cookie
    case cookie2
    case expect
    case ifMatch
    case ifModifiedSince
    case ifRange
    case ifNoneMatch
    case ifUnmodifiedSince
    case transferEncoding
    case userAgent
    case custom(String)
}

extension HTTPRequestHeaderField: Hashable {
    public var key: String {
        switch self {
        case .accept: return "Accept"
        case .acceptCharset: return "Accept-Charset"
        case .acceptEncoding: return "Accept-Encoding"
        case .acceptLanguage: return "Accept-Language"
        case .authorization: return "Authorization"
        case .cacheControl: return "Cache-Control"
        case .contentMD5: return "Content-MD5"
        case .contentLength: return "Content-Length"
        case .contentTransferEncoding: return "Content-Transfer-Encoding"
        case .contentType: return "Content-Type"
        case .cookie: return "Cookie"
        case .cookie2: return "Cookie 2"
        case .expect: return "Expect"
        case .ifMatch: return "If-Match"
        case .ifModifiedSince: return "If-Modified-Since"
        case .ifRange: return "If-Range"
        case .ifNoneMatch: return "If-None-Match"
        case .ifUnmodifiedSince: return "If-Unmodified-Since"
        case .transferEncoding: return "Transfer-Encoding"
        case .userAgent: return "User-Agent"
        case .custom(let v): return v
        }
    }
    
    public static func ==(lhs: HTTPRequestHeaderField, rhs: HTTPRequestHeaderField) -> Bool {
        return lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

public enum MediaType: String {
    case appJavascript = "application/javascript"
    case appJSON = "application/json"
    case appXWWWFormURLencoded = "application/x-www-form-urlencoded"
    case appXML = "application/xml"
    case appZIP = "application/zip"
    case appPDF = "application/pdf"
    case appSQL = "application/sql"
    case appGraphql = "application/graphql"
    case appLdJSON = "application/ld+json"
    case appMSWordDoc = "application/msword (.doc)"
    case appVNDDocx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document(.docx)"
    case appVNDXls = "application/vnd.ms-excel (.xls)"
    case appVNDXlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet (.xlsx)"
    case appVNDPpt = "application/vnd.ms-powerpoint (.ppt)"
    case appVNDPptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation (.pptx)"
    case appVNDOdt = "application/vnd.oasis.opendocument.text (.odt)"
    case audioMPEG = "audio/mpeg"
    case audioVorbis = "audio/vorbis"
    case multipartFormData = "multipart/form-data"
    case textCSS = "text/css"
    case textHTML = "text/html"
    case textCSV = "text/csv"
    case textPlain = "text/plain"
    case imagePNG = "image/png"
    case imageJPEG = "image/jpeg"
    case imageGIF = "image/gif"
}
