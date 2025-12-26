//
//  ResolveAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-24.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ResolveAction: SimpleLabelAction {
    let entity: Report
}

// MARK: - Configurability

extension ActionSeed {
    static let resolveReport = ActionSeed("resolveReport") { entity in
        switch entity {
        case let entity as Report: ResolveAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ResolveAction {
    static let resolveLabel: ActionLabel = .init(
        "Resolve",
        icon: .init("checkmark.circle"),
        color: .themedPositive
    )
    
    static let unresolveLabel: ActionLabel = .init(
        "Unresolve",
        icon: .init("xmark.circle"),
        color: .themedNegative
    )
    
    static var label: ActionLabel { resolveLabel }
    
    func createLabel(environment: EnvironmentValues) -> Actions.ActionLabel {
        entity.resolved ? Self.unresolveLabel : Self.resolveLabel
    }
    
    func execute(environment: EnvironmentValues) {
        entity.toggleResolved()
    }
}
