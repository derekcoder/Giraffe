//
//  Giraffe.swift
//  Giraffe
//
//  Created by Derek on 10/6/19.
//

import Foundation

public typealias JSONDictionary = [String: Any]
public typealias Parameters = [String: String]
public typealias Headers = [HTTPRequestHeaderField: String]

public extension JSONDictionary {
  var stringValue: String {
    let data = try! JSONSerialization.data(withJSONObject: self)
    return String(data: data, encoding: .utf8) ?? ""
  }
}

public extension Array where Element == JSONDictionary {
  var stringValue: String {
    let data = try! JSONSerialization.data(withJSONObject: self)
    return String(data: data, encoding: .utf8) ?? ""
  }
}
