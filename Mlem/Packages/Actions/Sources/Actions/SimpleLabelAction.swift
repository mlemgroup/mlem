//
//  SimpleLabelAction.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import SwiftUI

public protocol SimpleLabelAction: Action {
    static var label: ActionLabel { get }
}

public extension SimpleLabelAction {
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label
    }
}
