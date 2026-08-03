//
//  ActionSeed.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-16.
//

import Foundation

public final class ActionSeed: Hashable, Encodable {
    public let key: String
    private let actionType: any Action.Type
    
    public let appearance: ActionAppearance
    public let createAction: (Any) -> (any Action)?

    public init<T: Action>(
        _ key: String,
        appearance: ActionAppearance,
        createAction: @escaping (Any) -> T?
    ) {
        self.key = key
        self.appearance = appearance
        self.createAction = createAction
        self.actionType = T.self
    }

    public convenience init<T: SimpleLabelAction>(
        _ key: String,
        createAction: @escaping (Any) -> T?
    ) {
        self.init(key, appearance: T.appearance, createAction: createAction)
    }
    
    public static func == (lhs: ActionSeed, rhs: ActionSeed) -> Bool {
        lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public func encode(to encoder: any Encoder) throws {
        try self.key.encode(to: encoder)
    }
}
