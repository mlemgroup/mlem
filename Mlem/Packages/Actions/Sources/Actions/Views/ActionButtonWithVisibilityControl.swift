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
    private let labelType: ActionLabelType
    
    public init(_ action: any Action, describing labelType: ActionLabelType) {
        self.action = action
        self.labelType = labelType
    }
    
    public var body: some View {
        let appearance = action.createAppearance(environment: environment)
        if appearance.visibility != .hidden {
            Button(appearance, describing: labelType) {
                action.execute(environment: environment)
            }
            .disabled(appearance.visibility == .disabled)

            // Without this, destructive items appear black in the
            // subscription list due to a shim we've got in there #2374.
            // Intentionally unthemed.
            .tint(appearance.isDestructive ? .red : .primary)
        }
    }
}
