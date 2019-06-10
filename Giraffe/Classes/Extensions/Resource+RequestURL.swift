//
//  Resource+URL.swift
//  Giraffe
//
//  Created by Derek on 10/6/19.
//

import Foundation

extension Resource {
    var requestURL: URL {
        if var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let parameters = parameters,
            !parameters.isEmpty {
            
            let queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
            urlComponent.queryItems = queryItems
            
            if let newURL = urlComponent.url {
                return newURL
            }
        }
        return url
    }
}
