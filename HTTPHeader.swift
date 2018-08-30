//
//  Header.swift
//  Giraffe
//
//  Created by Derek on 30/8/18.
//

import Foundation

public enum HTTPRequestHeaderField: String {
    case accept = "Accept"
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    
    case cacheControl = "Cache-Control"
    case contentMD5 = "Content-MD5"
    case contentLength = "Content-Length"
    case contentTransferEncoding = "Content-Transfer-Encoding"
    case contentType = "Content-Type"
    case cookie = "Cookie"
    case cookie2 = "Cookie 2"
    
    case expect = "Expect"
    
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifRange = "If-Range"
    case ifNoneMatch = "If-None-Match"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    
    case transferEncoding = "Tranfer-Encoding"

    case userAgent = "User-Agent"
}

public enum HTTPResponseHeaderField: String {
    case allow = "Allow"
    
    case connection = "Connection"
    case contentDisposition = "Content-Disposition"
    case contentEncoding = "Content-Encoding"
    case contentLanguage = "Content-Language"
    case contentLength = "Content-Length"
    case contentLocation = "Content-Location"
    case contentMD5 = "Content-MD5"
    case contentRange = "Content-Range"
    case contentType = "Content-Type"
    
    case date = "Date"
    case deltaBase = "Delta-Base"
    
    case expires = "Expires"
    case im = "IM"
    case lastModified = "Last-Modified"
    case link = "Link"
    case location = "Location"
    case pragma = "Pragma"
    case proxyAuthenticate = "Proxy-Authenticate"
    case publicKeyPins = "Public-Key-Pins"
    case retryAfter = "Retry-After"
    case server = "Server"
    case setCookie = "Set-Cookie"
    case strictTransportSecurity = "Strict-Transport-Security"
    case trailer = "Trailer"
    case transferEncoding = "Transfer-Encoding"
    case tk = "Tk"
    case upgrade = "Upgrade"
    case vary = "Vary"
    case via = "Via"
    case warning = "Warning"
    case wwwAuthenticate = "WWW-Authenticate"
    case xFrameOptions = "X-Frame-Options"
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
