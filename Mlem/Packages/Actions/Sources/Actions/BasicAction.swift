//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import Icons
import SwiftUI

/// A basic implementation of `Action` designed for use in non-customizable contexts, such as the options within an alert.
///
/// ```swift
/// BasicAction("Confirm", icon: .general.success) {
///       post.upvote()
/// }
/// ```
///
public struct BasicAction: Action {
    private let appearance: ActionAppearance
    private let callback: () -> Void

    public init(
        _ title: LocalizedStringResource,
        icon: Icon,
        callback: @escaping () -> Void
    ) {
        self.appearance = .init(title, icon: icon)
        self.callback = callback
    }

    @_disfavoredOverload
    public init(
        _ title: String,
        icon: Icon,
        callback: @escaping () -> Void
    ) {
        self.appearance = .init(title, icon: icon)
        self.callback = callback
    }

    public func createAppearance(environment: EnvironmentValues) -> ActionAppearance { appearance }
    
    public func execute(environment: EnvironmentValues) { callback() }
}
