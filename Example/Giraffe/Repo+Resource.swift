//
//  Repo+Resource.swift
//  Giraffe_Example
//
//  Created by Derek on 30/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Giraffe

struct Config {
    static let baseURL = URL(string: "https://api.github.com")!
}

extension Repo {
    init?(json: JSONDictionary) {
        guard let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let fullName = json["full_name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.fullName = fullName
    }
    
    static func searchResource(text: String) -> Resource<[Repo]> {
        let url = Config.baseURL.appendingPathComponent("search/repositories").encoded(parameters: ["q": "\(text)+language:swift"])
        return Resource(url: url, parseJSON: { json, response in
            guard let dict = json as? JSONDictionary else { return Result(WebserviceError.jsonParsingFailed) }
            guard let itemsDict = dict["items"] as? [JSONDictionary] else { return Result(WebserviceError.jsonParsingFailed) }
            let repos = itemsDict.compactMap(Repo.init)
            return Result(repos)
        })
    }
}
