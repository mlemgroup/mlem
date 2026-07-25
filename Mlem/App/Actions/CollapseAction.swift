//
//  CollapseAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CollapseAction: SimpleLabelAction {
    let entity: Comment
}

// MARK: - Configurability

extension ActionSeed {
    static let collapse = ActionSeed("collapse") { entity in
        switch entity {
        case let entity as Comment: CollapseAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension CollapseAction {
    static let collapseAppearance: ActionAppearance = .init(
        "Collapse",
        icon: .general.collapse,
        color: .themedColorfulAccent(0)
    )

    static let expandAppearance: ActionAppearance = .init(
        "Expand",
        icon: .general.expand,
        color: .themedColorfulAccent(0)
    )

    static var appearance: ActionAppearance { collapseAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        guard let node = environment.commentTreeTracker?.getNode(actorId: entity.actorId) else {
            return Self.appearance.withVisibility(.hidden)
        }
        if node.collapsed {
            return Self.expandAppearance
        } else {
            return Self.collapseAppearance
        }
    }
}

// MARK: - Behavior

extension CollapseAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if let node = environment.commentTreeTracker?.getNode(actorId: entity.actorId) {
            withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                node.collapsed.toggle()
            }
        }
    }
}
