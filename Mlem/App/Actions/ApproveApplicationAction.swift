//
//  ApproveApplicationAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-08.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ApproveApplicationAction: SimpleLabelAction {
    let application: RegistrationApplication
}

// MARK: - Configurability

extension ActionSeed {
    static let approveApplication = ActionSeed("approveApplication") { entity in
        switch entity {
        case let entity as RegistrationApplication: ApproveApplicationAction(application: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ApproveApplicationAction {
    static var appearance: ActionAppearance {
        .init(
            "Approve",
            icon: .lemmy.approveApplication,
            color: .themedPositive,
            isDestructive: false,
            visibility: .enabled
        )
    }
}

// MARK: - Behavior

extension ApproveApplicationAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        application.approve()
    }
}
