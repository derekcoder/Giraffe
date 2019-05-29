//
//  CallbackQueue.swift
//  Giraffe
//
//  Created by Derek on 9/4/19.
//

import Foundation

public enum CallbackQueue {
    case mainAsync
    case globalAsync
    
    public func execute(_ block: @escaping () -> ()) {
        switch self {
        case .mainAsync: DispatchQueue.main.async { block() }
        case .globalAsync: DispatchQueue.global().async { block() }
        }
    }
}
