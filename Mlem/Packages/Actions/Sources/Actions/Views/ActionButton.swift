//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import SwiftUI

public struct ActionButton: View {
    @Environment(\.self) private var environment
    
    private let action: any Action
    
    public init(_ action: any Action) {
        self.action = action
    }
    
    public var body: some View {
        let label = action.createLabel(environment: environment)
        if label.visibility != .hidden {
            Button(role: label.isDestructive ? .destructive : nil) {
                action.execute(environment: environment)
            } label: {
                Label(label)
            }
            .disabled(label.visibility == .disabled)
        }
    }
}
