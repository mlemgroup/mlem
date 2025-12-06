//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import Foundation
import Icons
import Theming

public struct ActionLabel {
    public let title: String
    public var icon: Icon
    public var color: ThemedColor
    public var isDestructive: Bool
    public var visibility: ActionVisiblity
    
    public init(
        _ title: LocalizedStringResource,
        icon: Icon,
        color: ThemedColor = .themedAccent,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled
    ) {
        self.title = .init(localized: title)
        self.icon = icon
        self.color = color
        self.isDestructive = isDestructive
        self.visibility = visibility
    }
    
    @_disfavoredOverload
    public init(
        _ title: String,
        icon: Icon,
        color: ThemedColor = .themedAccent,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isDestructive = isDestructive
        self.visibility = visibility
    }
    
    public func withVisibility(_ visibility: ActionVisiblity) -> ActionLabel {
        var new = self
        new.visibility = visibility
        return new
    }
}
