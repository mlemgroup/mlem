//
//  CollapseToTopAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CollapseToTopAction: SimpleLabelAction {
    let entity: Comment
}

// MARK: - Configurability

extension ActionSeed {
    static let collapseToTop = ActionSeed("collapseToTop") { entity in
        switch entity {
        case let entity as Comment: CollapseToTopAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension CollapseToTopAction {
    static let label: ActionLabel = .init(
        "Collapse to Top",
        icon: .lemmy.collapseToTop,
        color: .themedColorfulAccent(0)
    )

   func createLabel(environment: EnvironmentValues) -> ActionLabel {
       return Self.label.withVisibility(visibility(environment: environment))
    }

    func visibility(environment: EnvironmentValues) -> ActionVisiblity {
        if environment.commentTreeTracker?.hasNode(actorId: entity.actorId) ?? false {
            .enabled
        } else {
            .hidden
        }
    }
}

// MARK: - Behavior

extension CollapseToTopAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if let node = environment.commentTreeTracker?.getNode(actorId: entity.actorId) {
            withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                node.topParent.collapsed.toggle()
            }
        }
    }
}
