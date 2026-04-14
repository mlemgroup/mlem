//
//  SignUpAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-16.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SignUpAction: SimpleLabelAction {
    let instance: InstanceStub
}

// MARK: - Configurability

extension ActionSeed {
    static let signUp = ActionSeed("signUp") { entity in
        switch entity {
        case let entity as any InstanceActionProviding: SignUpAction(instance: entity.instanceStub)
        default: nil
        }
    }
}

// MARK: - Appearance

extension SignUpAction {
    static let label: ActionLabel = .init("Sign Up", icon: .lemmy.signUp)
}

// MARK: - Behavior

extension SignUpAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.signUp(instance))
    }
}
