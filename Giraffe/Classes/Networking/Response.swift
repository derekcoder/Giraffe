//
//  Response.swift
//  Giraffe
//
//  Created by derekcoder on 8/4/19.
//

import Foundation

public struct Response<A> {
  public var result: Result<A, APIError>
  
  public let data: Data?
  public let error: Error?
  public let httpResponse: HTTPURLResponse?
}
