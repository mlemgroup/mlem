//
//  CollapseParentAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CollapseParentAction: SimpleLabelAction {
    let entity: Comment
}

// MARK: - Configurability

extension ActionSeed {
    static let collapseParent = ActionSeed("collapseParent") { entity in
        switch entity {
        case let entity as Comment: CollapseParentAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension CollapseParentAction {
    static let label: ActionLabel = .init(
        "Collapse Parent",
        icon: .lemmy.collapseParent,
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

extension CollapseParentAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if let node = environment.commentTreeTracker?.getNode(actorId: entity.actorId) {
            withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                (node.parent ?? node).collapsed.toggle()
            }
        }
    }
}
