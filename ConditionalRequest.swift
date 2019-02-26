//
//  ConditionalRequest.swift
//  Giraffe
//
//  Created by derekcoder on 26/2/19.
//

import Foundation

public class ConditionalRequest {
    var eTag: String
    var pollInterval: Double
    var lastRequested: Date
    
    init(eTag: String, pollInterval: Double, lastRequested: Date) {
        self.eTag = eTag
        self.pollInterval = pollInterval
        self.lastRequested = lastRequested
    }
    
    var isAvailabelForPolling: Bool {
        let pollingDate = Date(timeInterval: pollInterval, since: lastRequested)
        return Date() > pollingDate
    }
}
