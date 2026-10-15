//
//  QuickSwipeAction+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-18.
//

import Actions
import Icons
import QuickSwipes
import SwiftUI

private extension QuickSwipeAction {
    init?(appearance: ActionAppearance, callback: @escaping () -> Void) {
        if appearance.visibility == .hidden { return nil }
        let label = appearance.label(describing: .stateTransition)
        self.init(
            icon: label.icon,
            color: label.color,
            enabled: appearance.visibility == .enabled,
            confirmationPrompt: nil,
            callback: callback
        )
    }
}

private struct QuickSwipesActionsViewModifier: ViewModifier {
    @Environment(\.self) var environment
    
    let leadingActions: [any Action]
    let trailingActions: [any Action]
    let leadingBuffer: SwipeBuffer

    func body(content: Content) -> some View {
        content
            .quickSwipes(config)
    }

    var config: SwipeConfiguration {
        .init(
            leadingActions: leadingActions.compactMap(self.createAction),
            trailingActions: trailingActions.compactMap(self.createAction),
            leadingBuffer: leadingBuffer
        )
    }

    func createAction(_ action: any Action) -> QuickSwipeAction? {
        .init(
            appearance: action.createAppearance(environment: environment),
            callback: { action.execute(environment: environment) }
        )
    }
}

extension View {
    @ViewBuilder
    func quickSwipes(
        leading: [any Action] = [],
        trailing: [any Action] = [],
        leadingBuffer: SwipeBuffer
    ) -> some View {
        modifier(QuickSwipesActionsViewModifier(
            leadingActions: leading,
            trailingActions: trailing,
            leadingBuffer: leadingBuffer
        ))
    }

}
