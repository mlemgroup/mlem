//
//  DeletableProviding.swift
//
//
//  Created by Sjmarf on 22/07/2024.
//

import Foundation

public protocol DeletableProviding: ContentIdentifiable {
    var deleted: Bool { get }
    
    func updateDeleted(_ newValue: Bool, callback: ((Bool) -> Void)?)
}

public extension DeletableProviding {
    func toggleDeleted(callback: ((Bool) -> Void)? = nil) {
        updateDeleted(!deleted, callback: callback)
    }
}
