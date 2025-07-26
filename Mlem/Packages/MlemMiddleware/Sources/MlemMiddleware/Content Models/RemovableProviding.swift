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
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((UpdateStatus) -> Void)?)
}

public extension RemovableProviding {
    /// Toggles the removed status of this item
    /// - Parameters: callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func toggleRemoved(reason: String?, callback: ((UpdateStatus) -> Void)? = nil) {
        updateRemoved(!removed, reason: reason, callback: callback)
    }
}
