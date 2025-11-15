//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-14.
//

import SwiftUI

// This type can be used inside of a `.contextMenu()` rather than using the `ForEach` directly.
// This avoids instantiating the actions until the menu is actually opened.

public struct ActionButtons: View {
    @Environment(\.self) var environment
    
    let actions: (EnvironmentValues) -> [any Actions.Action]
    
    public init(_ actions: @escaping (EnvironmentValues) -> [any Actions.Action]) {
        self.actions = actions
    }

    public var body: some View {
        ForEach(Array(actions(environment).enumerated()), id: \.offset) { _, action in
            ActionButtonWithVisibilityControl(action)
        }
    }
}
