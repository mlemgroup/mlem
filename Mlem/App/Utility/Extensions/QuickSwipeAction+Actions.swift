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
    
    let leadingActions: [any Actions.Action]
    let trailingActions: [any Actions.Action]
    let leadingBuffer: CGFloat

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

    func createAction(_ action: any Actions.Action) -> QuickSwipeAction? {
        .init(
            label: action.createLabel(environment: environment),
            callback: { action.execute(environment: environment) }
        )
    }
}

public enum SwipeBuffer {
    case none, tile, standard
    
    var value: CGFloat {
        switch self {
        case .none: 0
        case .tile: 50
        case .standard: 70
        }
    }
}

extension View {
    @ViewBuilder
    func quickSwipes(leading: [any Actions.Action], trailing: [any Actions.Action], leadingBuffer: SwipeBuffer) -> some View {
        modifier(QuickSwipesActionsViewModifier(
            leadingActions: leading,
            trailingActions: trailing,
            leadingBuffer: leadingBuffer.value
        ))
    }
}
