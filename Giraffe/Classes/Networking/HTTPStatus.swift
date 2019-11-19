//
//  HTTPStatus.swift
//  Giraffe
//
//  Created by Derek on 19/11/19.
//

import Foundation

public struct HTTPStatus {
  public static let ok = 200
  public static let created = 201
  public static let accepted = 202
  public static let noContent = 204
  
  public static let notModified = 304
  
  public static let badRequst = 400
  public static let unauthorized = 401
  public static let forbidden = 403
  public static let notFound = 404
  public static let requestTimeout = 408
  public static let conflict = 409
  
  public static let internalServerError = 500
  public static let notImplemented = 501
  public static let badGateway = 502
  public static let serviceUnavailable = 503
  public static let gatewayTimeout = 504
}
