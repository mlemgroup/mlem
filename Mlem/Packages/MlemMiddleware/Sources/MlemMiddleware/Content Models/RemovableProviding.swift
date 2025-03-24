//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-15.
//

import Foundation

public protocol RemovableProviding: ContentIdentifiable {
    var removedManager: StateManager<Bool> { get }
    var removed: Bool { get }
    
    @discardableResult
    func updateRemoved(_ newValue: Bool, reason: String?) -> Task<StateUpdateResult, Never>
}

public extension RemovableProviding {
    @discardableResult
    func toggleRemoved(reason: String?) -> Task<StateUpdateResult, Never> {
        updateRemoved(!removed, reason: reason)
    }
}
