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
    let entity: any ReportableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let resolveReport = ActionSeed("resolveReport") { entity in
        switch entity {
        case let entity as any ReportableProviding: ResolveAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ResolveAction {
    static let resolveAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Unresolved", icon: .lemmy.resolved.representingState(active: false)),
        stateTransitionLabel: .init("Resolve", icon: .lemmy.resolve),
        color: .themedPositive
    )

    static let unresolveAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Resolved", icon: .lemmy.resolved.representingState(active: true)),
        stateTransitionLabel: .init("Unresolve", icon: .lemmy.unresolve),
        color: .themedNegative,
        prominent: true
    )

    static var appearance: ActionAppearance { resolveAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        let resolved = environment.reportContext?.resolved ?? false
        let appearance = resolved ? Self.unresolveAppearance : Self.resolveAppearance
        return appearance.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        environment.reportContext != nil ? .enabled : .hidden
    }

    func execute(environment: EnvironmentValues) {
        environment.reportContext?.toggleResolved()
    }
}
