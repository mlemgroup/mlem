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
    init?(label: ActionLabel, callback: @escaping () -> Void) {
        if label.visibility == .hidden { return nil }
        self.init(
            icon: label.icon,
            color: label.color,
            enabled: label.visibility == .enabled,
            confirmationPrompt: nil,
            callback: callback
        )
    }
}

private struct QuickSwipesActionsViewModifier: ViewModifier {
    @Environment(\.self) var environment
    @Setting(\.post_size) var postSize

    let leadingActions: [any Actions.Action]
    let trailingActions: [any Actions.Action]

    func body(content: Content) -> some View {
        content
            .quickSwipes(config)
    }

    var config: SwipeConfiguration {
        .init(
            leadingActions: leadingActions.compactMap(self.createAction),
            trailingActions: trailingActions.compactMap(self.createAction),
            leadingBuffer: postSize == .tile ? 50 : 70
        )
    }

    func createAction(_ action: any Actions.Action) -> QuickSwipeAction? {
        .init(
            label: action.createLabel(environment: environment),
            callback: { action.execute(environment: environment) }
        )
    }
}

extension View {
    @ViewBuilder
    func quickSwipes(leading: [any Actions.Action], trailing: [any Actions.Action]) -> some View {
        modifier(QuickSwipesActionsViewModifier(
            leadingActions: leading,
            trailingActions: trailing
        ))
    }
}
