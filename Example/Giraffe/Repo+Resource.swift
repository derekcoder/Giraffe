//
//  Repo+Resource.swift
//  Giraffe_Example
//
//  Created by Derek on 30/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Giraffe

extension Repo {
  static let endPoint = URL(string: "https://api.github.com/repos")!
  
  init?(json: JSONDictionary) {
    guard let id = json["id"] as? Int,
      let fullName = json["full_name"] as? String else { return nil }
    self.id = id
    self.fullName = fullName
    self.description = json["description"] as? String
  }
  
  var resource: Resource<Repo> {
    let url = Repo.endPoint.appendingPathComponent(fullName)
    return Resource(url: url, parseJSON: { obj in
      guard let json = obj as? JSONDictionary,
        let repo = Repo(json: json) else {
        return Result.failure(.invalidResponse)
      }
      return Result.success(repo)
    })
  }
}
