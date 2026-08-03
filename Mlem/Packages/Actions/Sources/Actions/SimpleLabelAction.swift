//
//  SimpleLabelAction.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import SwiftUI

public protocol SimpleLabelAction: Action {
    static var appearance: ActionAppearance { get }
}

public extension SimpleLabelAction {
    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        Self.appearance
    }
}
