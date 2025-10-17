//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import SwiftUI

/// A child protocol of `Action` that allows for the `Action` to be used in customizable contexts,
/// such as the interaction bar or swipe actions.
///
public protocol ConfigurableAction: Action {
    /// A contextless label used to represent the action in a customization UI.
    static var label: ActionLabel { get }
}

public extension ConfigurableAction {
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label
    }
}
