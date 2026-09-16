//
//  ActionLabel.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-25.
//

import Foundation
import Icons
import Theming

public struct ActionLabel {
    public let title: String
    public let icon: Icon
    public let color: ThemedColor

    public init(_ title: LocalizedStringResource, icon: Icon, color: ThemedColor) {
        self.title = .init(localized: title)
        self.icon = icon
        self.color = color
    }
    
    @_disfavoredOverload
    public init(_ title: some StringProtocol, icon: Icon, color: ThemedColor) {
        self.title = String(title)
        self.icon = icon
        self.color = color
    }

    internal init(_ label: ActionLabelWithoutColor, color: ThemedColor) {
        self.title = label.title
        self.icon = label.icon
        self.color = color
    }
}
