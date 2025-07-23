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
    /// Toggles the removed status of this item
    /// - Parameters: callback: if present, when the repository call completes, is called with `true` if the operation succeeded and `false` otherwise.
    /// - Note: the callback's parameter indicates success/failure, not removed/restored.
    func toggleRemoved(reason: String?, callback: ((Bool) -> Void)? = nil) throws {
        try updateRemoved(!removed, reason: reason, callback: callback)
    }
}
