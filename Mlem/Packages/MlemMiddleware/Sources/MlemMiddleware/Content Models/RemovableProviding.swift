//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-15.
//

import Foundation

public protocol RemovableProviding: ContentIdentifiable {
    var removed: Bool { get }
    var removedPending: Bool { get }
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((Bool) -> Void)?) throws
}

public extension RemovableProviding {
    func toggleRemoved(reason: String?, callback: ((Bool) -> Void)? = nil) throws {
        try updateRemoved(!removed, reason: reason, callback: callback)
    }
}
