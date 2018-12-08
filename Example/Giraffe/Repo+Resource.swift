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
            let fullName = json["full_name"] as? String else { return nil }
        self.id = id
        self.fullName = fullName
        self.description = json["description"] as? String
    }
    
    static func searchResource(text: String) -> Resource<[Repo]> {
        let url = Config.baseURL.appendingPathComponent("search/repositories").encoded(parameters: ["q": "\(text)+language:swift"])
        return Resource(url: url, parseJSON: { json, response, error in
            guard let dict = json as? JSONDictionary, let itemsDict = dict["items"] as? [JSONDictionary] else {
                return Result(error: GiraffeError.jsonParsingFailed)
            }
            let repos = itemsDict.compactMap(Repo.init)
            return Result(value: repos)
        })
    }
    
    var resource: Resource<Repo> {
        let url = Config.baseURL.appendingPathComponent("repos/\(fullName)")
        return Resource(url: url, parseJSON: { obj, _, _ in
            guard let json = obj as? JSONDictionary, let repo = Repo(json: json) else {
                return Result(error: GiraffeError.jsonParsingFailed)
            }
            return Result(value: repo)
        })
    }
}
