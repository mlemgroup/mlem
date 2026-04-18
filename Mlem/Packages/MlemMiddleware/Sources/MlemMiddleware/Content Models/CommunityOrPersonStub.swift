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


public protocol Blockable: ActorIdentifiable {
    /// Whether the entity knows itself to be blocked.
    /// - Note: Some types (e.g., `InstanceSummary`) do not track blocked status. For the most accurate blocked status, use
    /// `blocked(environment: EnvironmentValues)` as defined in Mlem
    /// - Warning: there is a Swift compiler bug that causes compilation to fail if you reference `blocked.realizedValue` in
    /// certain contexts. It is recommended to use `blocked_.realizedValue` any time you are working with a concrete type.
    var blocked: any RealizedValueProviding<Bool> { get }

    /// Updates the blocked status to the given value
    /// - Parameters:
    ///   - newValue: intended block status
    ///   - callback: if present, will be called when the block completes with true if the update succeeds and false otherwise.
    var updateBlocked: ((Bool, ((Bool) -> Void)?) -> Void)? { get }
}
