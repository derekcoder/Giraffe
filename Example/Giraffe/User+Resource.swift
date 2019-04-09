//
//  User+Resource.swift
//  Giraffe_Example
//
//  Created by derekcoder on 8/12/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Giraffe

extension User {
    init?(json: JSONDictionary) {
        guard let id = json["id"] as? Int,
            let login = json["login"] as? String else { return nil }
        self.id = id
        self.login = login
        self.avatar = json["avatar_url"] as? String
        self.name = json["name"] as? String
    }
    
    static func resource(for login: String) -> Resource<User> {
        let url = Config.baseURL.appendingPathComponent("users/\(login)")
        return Resource(url: url) { response in
            guard let obj = response.jsonObject,
                let json = obj as? JSONDictionary,
                let user = User(json: json) else {
                return Result.failure(.invalidResponse)
            }
            return Result.success(user)
        }
    }
    
    var avatarResource: Resource<UIImage?>? {
        guard let avatar = avatar else { return nil }
        guard let url = URL(string: avatar) else { return nil }
        return Resource(url: url) { response in
            if let data = response.data {
                return Result.success(UIImage(data: data))
            } else {
                return Result.success(nil)
            }
        }
    }
    
    var reposResource: Resource<[Repo]> {
        let url = Config.baseURL.appendingPathComponent("/users/\(login)/repos")
                    .appendingQueryItems(["sort": "pushed"])
        return Resource(url: url) { response in
            guard let obj = response.jsonObject,
                let json = obj as? [JSONDictionary] else {
                return Result.failure(.invalidResponse)
            }
            let repos = json.compactMap(Repo.init)
            return Result.success(repos)
        }
    }
}
