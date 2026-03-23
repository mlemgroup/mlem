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
    static let collapseLabel: ActionLabel = .init(
        "Collapse",
        icon: .general.collapse,
        color: .themedColorfulAccent(0)
    )

    static let expandLabel: ActionLabel = .init(
        "Expand",
        icon: .general.expand,
        color: .themedColorfulAccent(0)
    )

   static var label: ActionLabel { collapseLabel }

   func createLabel(environment: EnvironmentValues) -> ActionLabel {
       guard let node = environment.commentTreeTracker?.getNode(actorId: entity.actorId) else {
           return Self.label.withVisibility(.hidden)
       } 
       if node.collapsed {
           return Self.expandLabel
       } else {
           return Self.collapseLabel
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
