//
//  ActionSeed.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-16.
//

import Foundation

public struct ActionSeed: Hashable {
    public let key: String
    private let actionType: any ConfigurableAction.Type
    
    public let label: ActionLabel
    public let createAction: (Any) -> (any ConfigurableAction)?
    
    public init<T: ConfigurableAction>(
        _ key: String,
        label: ActionLabel? = nil,
        createAction: @escaping (Any) -> T?
    ) {
        self.key = key
        self.label = label ?? T.label
        self.createAction = createAction
        self.actionType = T.self
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}
