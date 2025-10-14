//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-14.
//

import Foundation

/// A wrapper for `any ConfigurableAction.Type` that conforms to the `Codable` protocol.
///
/// `ActionToken` is encoded as a `String`. It uses the `configurationKey` of the
/// wrapped `ConfigurableAction` type.
///
/// `ActionToken` can be decoded from a `String`, too. To look up the relevant action, it needs access
/// to an `ActionRegistry`, which stores all of the action types. To provide an `ActionRegistry`,
/// call `withActionRegistry(_: )` on your `JSONDecoder` before you use it to decode the
/// `ActionToken`.
///
public struct ActionToken: Codable {
    public let actionType: any ConfigurableAction.Type
    
    public init(_ actionType: any ConfigurableAction.Type) {
        self.actionType = actionType
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(actionType.configurationKey)
    }
    
    public init(from decoder: any Decoder) throws {
        guard let actionRegistry = decoder.userInfo[.actionRegistry] as? ActionRegistry else {
            throw ActionTokenError.registryNotFound
        }
        
        let container = try decoder.singleValueContainer()
        let key = try container.decode(String.self)
        
        guard let action = actionRegistry.action(forKey: key) else {
            throw ActionTokenError.keyNotRegistered(key: key)
        }
        
        self.actionType = action
    }
}

public enum ActionTokenError: Error {
    case registryNotFound
    case keyNotRegistered(key: String)
}
