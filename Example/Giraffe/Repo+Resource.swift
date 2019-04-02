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
    init?(json: JSONDictionary) {
        guard let id = json["id"] as? Int,
            let fullName = json["full_name"] as? String else { return nil }
        self.id = id
        self.fullName = fullName
        self.description = json["description"] as? String
    }
    
    static func searchResource(text: String) -> Resource<[Repo]> {
        let url = Config.baseURL.appendingPathComponent("search/repositories")
                    .appendingQueryItems(["q": "\(text)+language:swift"])
        return Resource(url: url, parseJSON: { obj, _, _, isCached in
            guard let json = obj as? JSONDictionary, let items = json["items"] as? [JSONDictionary] else {
                return Result(error: GiraffeError.invalidResponse)
            }
            let repos = items.compactMap(Repo.init)
            return Result(value: repos, isCached: isCached)
        })
    }
    
    var resource: Resource<Repo> {
        let url = Config.baseURL.appendingPathComponent("repos/\(fullName)")
        return Resource(url: url, parseJSON: { obj, _, _, isCached in
            guard let json = obj as? JSONDictionary, let repo = Repo(json: json) else {
                return Result(error: GiraffeError.invalidResponse)
            }
            return Result(value: repo, isCached: isCached)
        })
    }
}
