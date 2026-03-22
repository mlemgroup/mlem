//
//  LogInAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-16.
//

import Actions
import MlemMiddleware
import SwiftUI

struct LogInAction: SimpleLabelAction {
    let instance: Instance
}

// MARK: - Configurability

extension ActionSeed {
    static let logIn = ActionSeed("logIn") { entity in
        switch entity {
        case let entity as Instance: LogInAction(instance: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension LogInAction {
    static let label: ActionLabel = .init("Log In", icon: .lemmy.logIn)
}

// MARK: - Behavior

extension LogInAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.logIn(.instance(instance)))
    }
}
