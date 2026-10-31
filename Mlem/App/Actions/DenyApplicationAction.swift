//
//  DenyApplicationAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-08.
//

import Actions
import MlemMiddleware
import SwiftUI

struct DenyApplicationAction: SimpleLabelAction {
    let application: RegistrationApplication
}

// MARK: - Configurability

extension ActionSeed {
    static let denyApplication = ActionSeed("denyApplication") { entity in
        switch entity {
        case let entity as RegistrationApplication: DenyApplicationAction(application: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension DenyApplicationAction {
    static var appearance: ActionAppearance {
        .init(
            "Deny",
            icon: .lemmy.denyApplication,
            color: .themedNegative,
            isDestructive: true,
            visibility: .enabled
        )
    }
}

// MARK: - Behavior

extension DenyApplicationAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.denyApplication(application))
    }
}
