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
    let instance: any InstanceActionProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let logIn = ActionSeed("logIn") { entity in
        switch entity {
        case let entity as any InstanceActionProviding: LogInAction(instance: entity)
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
        if let instance = instance as? Instance {
            environment.navigation?.openSheet(.logIn(.instance(instance)))
        } else {
            environment.navigation?.openSheet(.instanceStub(instance.instanceStub) { .logIn(.instance($0)) })
        }
    }
}
