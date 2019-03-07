//
//  ConditionalRequestManager.swift
//  Giraffe
//
//  Created by derekcoder on 26/2/19.
//

import Foundation

public class ConditionalRequestManager {
    private var requests: [String: ConditionalRequest] = [:]
    
    func setConditionRequest(urlString: String, response: HTTPURLResponse) {
        let headers = response.allHeaderFields
        
        if response.statusCode == HTTPStatus.ok.rawValue {
            guard let eTag = headers["Etag"] as? String else { return }
            let pollInterval = Double((headers["X-Poll-Interval"] as? String) ?? "0") ?? 0.0
            
            if let request = requests[urlString] {
                request.eTag = eTag
                request.pollInterval = pollInterval
                request.lastRequested = Date()
            } else {
                let newRequest = ConditionalRequest(eTag: eTag, pollInterval: pollInterval, lastRequested: Date())
                requests[urlString] = newRequest
            }
        }
    }
    
    func isAvailabelForPolling(urlString: String) -> Bool {
        guard let request = requests[urlString] else { return true }
        return request.isAvailabelForPolling
    }
    
    func pollingETag(urlString: String) -> String? {
        guard let request = requests[urlString] else { return nil }
        return request.eTag
    }
    
    func removeConditionalRequest(urlString: String) {
        requests.removeValue(forKey: urlString)
    }
}
