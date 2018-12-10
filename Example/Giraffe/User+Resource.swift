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
        return Resource(url: url, parseJSON: { obj, _, _ in
            guard let json = obj as? JSONDictionary, let user = User(json: json) else {
                return Result(error: GiraffeError.invalidResponse)
            }
            return Result(value: user)
        })
    }
    
    var avatarResource: Resource<UIImage?>? {
        guard let avatar = avatar else { return nil }
        guard let url = URL(string: avatar) else { return nil }
        return Resource(url: url, parse: { data, _, _ in
            guard let data = data else { return Result(value: nil) }
            let image = UIImage(data: data)
            return Result(value: image)
        })
    }
    
    var reposResource: Resource<[Repo]> {
        let url = Config.baseURL.appendingPathComponent("/users/\(login)/repos").encoded(parameters: ["sort": "pushed"])
        return Resource(url: url, parseJSON: { obj, _, _ in
            guard let json = obj as? [JSONDictionary] else {
                return Result(error: GiraffeError.invalidResponse)
            }
            let repos = json.compactMap(Repo.init)
            return Result(value: repos)
        })
    }
}
