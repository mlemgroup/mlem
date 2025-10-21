//
//  DeletableProviding.swift
//
//
//  Created by Sjmarf on 22/07/2024.
//

import Foundation

public protocol DeletableProviding: OwnershipProviding {
    var deleted: Bool { get }
    
    func updateDeleted(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?)
}

public extension DeletableProviding {
    func toggleDeleted(callback: ((UpdateStatus) -> Void)? = nil) {
        updateDeleted(!deleted, callback: callback)
    }
}
