//
//  URL+QueryItems.swift
//  Giraffe
//
//  Created by Derek on 9/4/19.
//

import Foundation

public extension URL {
    mutating func appendQueryItems(_ items: [String: String]) {
        self = appendingQueryItems(items)
    }
    
    func appendingQueryItems(_ items: [String: String]) -> URL {
        guard var urlComps = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return self }
        
        let currentItems = urlComps.queryItems ?? []
        let filteredItems = currentItems.filter { !items.keys.contains($0.name) }
        let addingItems = items.map { URLQueryItem(name: $0, value: $1) }
        urlComps.queryItems = filteredItems + addingItems
        
        return urlComps.url ?? self
    }
}

public extension String {
    var escapedForURLQuery: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
