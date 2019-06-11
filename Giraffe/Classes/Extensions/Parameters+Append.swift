//
//  URL+QueryItems.swift
//  Giraffe
//
//  Created by Derek on 9/4/19.
//

import Foundation

extension Parameters {
    func appendingParameters(_ parameters: Parameters) -> Parameters {
        return self.merging(parameters) { _, new in new }
    }

    mutating func appendParameters(_ parameters: Parameters) {
        self = appendingParameters(parameters)
    }    
}
