//
//  View+QuickSwipes.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-23.
//

import Actions
import MlemMiddleware
import QuickSwipes
import SwiftUI

private struct QuickSwipeEnvironmentReaderViewModifier: ViewModifier {
    @Environment(\.self) var environment
    
    var buildConfiguration: (EnvironmentValues) -> SwipeConfiguration
    
    init(_ buildConfiguration: @escaping (EnvironmentValues) -> SwipeConfiguration) {
        self.buildConfiguration = buildConfiguration
    }
    
    func body(content: Content) -> some View {
        content.quickSwipes(buildConfiguration(environment))
    }
}

extension View {
    @ViewBuilder
    func quickSwipes(
        leading: [any Action] = [],
        trailing: [any Action] = [],
        leadingBuffer: SwipeBuffer
    ) -> some View {
        quickSwipes(.init(leadingActions: leading, trailingActions: trailing, leadingBuffer: leadingBuffer))
    }
}
