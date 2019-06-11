//
//  HTTPHeaderTests.swift
//  Giraffe_Tests
//
//  Created by Derek on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import Giraffe

class HTTPHeaderTests: XCTestCase {
    
    func testKey() {
        XCTAssertEqual(HTTPRequestHeaderField.accept.key, "Accept")
        XCTAssertEqual(HTTPRequestHeaderField.acceptCharset.key, "Accept-Charset")
        XCTAssertEqual(HTTPRequestHeaderField.acceptEncoding.key, "Accept-Encoding")
        XCTAssertEqual(HTTPRequestHeaderField.acceptLanguage.key, "Accept-Language")
        XCTAssertEqual(HTTPRequestHeaderField.authorization.key, "Authorization")
        XCTAssertEqual(HTTPRequestHeaderField.cacheControl.key, "Cache-Control")
        XCTAssertEqual(HTTPRequestHeaderField.contentMD5.key, "Content-MD5")
        XCTAssertEqual(HTTPRequestHeaderField.contentLength.key, "Content-Length")
        XCTAssertEqual(HTTPRequestHeaderField.contentTransferEncoding.key, "Content-Transfer-Encoding")
        XCTAssertEqual(HTTPRequestHeaderField.contentType.key, "Content-Type")
        XCTAssertEqual(HTTPRequestHeaderField.cookie.key, "Cookie")
        XCTAssertEqual(HTTPRequestHeaderField.cookie2.key, "Cookie 2")
        XCTAssertEqual(HTTPRequestHeaderField.expect.key, "Expect")
        XCTAssertEqual(HTTPRequestHeaderField.ifMatch.key, "If-Match")
        XCTAssertEqual(HTTPRequestHeaderField.ifModifiedSince.key, "If-Modified-Since")
        XCTAssertEqual(HTTPRequestHeaderField.ifRange.key, "If-Range")
        XCTAssertEqual(HTTPRequestHeaderField.ifNoneMatch.key, "If-None-Match")
        XCTAssertEqual(HTTPRequestHeaderField.ifUnmodifiedSince.key, "If-Unmodified-Since")
        XCTAssertEqual(HTTPRequestHeaderField.transferEncoding.key, "Transfer-Encoding")
        XCTAssertEqual(HTTPRequestHeaderField.userAgent.key, "User-Agent")
        XCTAssertEqual(HTTPRequestHeaderField.custom("x-username").key, "x-username")
    }

}
