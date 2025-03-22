//
//  DeletableProviding.swift
//  
//
//  Created by Sjmarf on 22/07/2024.
//

import Foundation

public protocol DeletableProviding: ContentIdentifiable {
    var deleted: Bool { get }
    
    @discardableResult
    func updateDeleted(_ newValue: Bool) -> Task<StateUpdateResult, Never>
}

public extension DeletableProviding {
    @discardableResult
    func toggleDeleted() -> Task<StateUpdateResult, Never> {
        updateDeleted(!deleted)
    }
}
