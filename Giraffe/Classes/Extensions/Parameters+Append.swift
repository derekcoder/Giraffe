//
//  URL+QueryItems.swift
//  Giraffe
//
//  Created by Derek on 9/4/19.
//

import Foundation

extension Parameters {
    func appendingParameters(_ parameters: Parameters) -> Parameters {
        return parameters.merging(self) { _, new in new }
    }

    mutating func appendParameters(_ parameters: Parameters) {
        self = appendingParameters(parameters)
    }    
}

public extension String {
    var escapedForURLQuery: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
