//
//  CommunityOrAccount.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import Observation

public protocol CommunityOrPerson: ContentModel, ActorIdentifiable {
    static var identifierPrefix: String { get }
    
    var name: String { get }
}

public extension CommunityOrPerson {
    var fullName: String { "\(name)@\(host)" }
    
    var fullNameWithPrefix: String { "\(Self.identifierPrefix)\(name)@\(host)" }
}


public protocol Blockable: ContentModel, ActorIdentifiable {
    var blocked: Bool { get }

    /// Updates the blocked status to the given value
    /// - Parameters:
    ///   - newValue: intended block status
    ///   - callback: if present, will be called when the block completes with true if the update succeeds and false otherwise.
    func updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)?)
}
