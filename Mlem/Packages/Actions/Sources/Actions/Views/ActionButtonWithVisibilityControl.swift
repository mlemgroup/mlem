//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import SwiftUI

public struct ActionButtonWithVisibilityControl: View {
    @Environment(\.self) private var environment
    
    private let action: any Action
    
    public init(_ action: any Action) {
        self.action = action
    }
    
    public var body: some View {
        let label = action.createLabel(environment: environment)
        if label.visibility != .hidden {
            Button(label) {
                action.execute(environment: environment)
            }
            .disabled(label.visibility == .disabled)

            // Without this, destructive items appear black in the
            // subscription list due to a shim we've got in there #2374.
            // Intentionally unthemed.
            .tint(label.isDestructive ? .red : .primary)
        }
    }
}
