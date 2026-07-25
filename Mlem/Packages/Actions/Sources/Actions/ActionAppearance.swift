//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import Foundation
import Icons
import Theming

public struct ActionAppearance {
    public var title: String
    public var icon: Icon
    public var color: ThemedColor
    public var isDestructive: Bool
    public var visibility: ActionVisiblity
    public var prominent: Bool
    
    public init(
        _ title: LocalizedStringResource,
        icon: Icon,
        color: ThemedColor = .themedAccent,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled,
        prominent: Bool = false
    ) {
        self.title = .init(localized: title)
        self.icon = icon
        self.color = color
        self.isDestructive = isDestructive
        self.visibility = visibility
        self.prominent = prominent 
    }
    
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        icon: Icon,
        color: ThemedColor = .themedAccent,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled,
        prominent: Bool = false
    ) {
        self.title = String(title)
        self.icon = icon
        self.color = color
        self.isDestructive = isDestructive
        self.visibility = visibility
        self.prominent = prominent
    }
    
    public func withVisibility(_ visibility: ActionVisiblity) -> ActionAppearance {
        var new = self
        new.visibility = visibility
        return new
    }

    public func withProminent(_ value: Bool) -> ActionAppearance {
        var new = self
        new.prominent = prominent
        return new
    }

    public func withTitle(_ title: LocalizedStringResource) -> ActionAppearance {
        var new = self
        new.title = .init(localized: title)
        return new
    }

    @_disfavoredOverload
    public func withTitle(_ title: some StringProtocol) -> ActionAppearance {
        var new = self
        new.title = String(title)
        return new
    }
}
