//
//  URL+QueryItems.swift
//  Giraffe
//
//  Created by Derek on 9/4/19.
//

import Foundation

extension Parameters {
    mutating func appendParameters(_ parameters: Parameters) {
        self = appendingParameters(parameters)
    }
    
    func appendingParameters(_ parameters: Parameters) -> Parameters {
        return parameters.merging(self) { _, new in new }
    }
}

public extension String {
    var escapedForURLQuery: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
