//
//  Webservice+Log.swift
//  Giraffe
//
//  Created by Derek on 28/5/19.
//

import Foundation

extension Webservice {
    func logMessage<A>(_ message: String, for resource: Resource<A>) {
        guard debugEnabled else { return }
        print("***** Giraffe: \(message) - \(resource.url.absoluteString)")
    }
}

