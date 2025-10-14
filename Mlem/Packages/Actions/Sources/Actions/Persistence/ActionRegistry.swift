//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-14.
//

import Foundation

public class ActionRegistry {
    private var actions: [String: any ConfigurableAction.Type]
    
    public init(_ actions: [any ConfigurableAction.Type]) {
        self.actions = actions.reduce(into: [:]) {
            $0[$1.configurationKey] = $1
        }
    }
    
    func action(forKey key: String) -> (any ConfigurableAction.Type)? {
        actions[key]
    }
}
