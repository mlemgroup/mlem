//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import Foundation
import Icons

public struct ActionLabel {
    public let title: String
    public var icon: Icon
    public var isDestructive: Bool
    public var visibility: ActionVisiblity
    
    public init(
        _ title: LocalizedStringResource,
        icon: Icon,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled
    ) {
        self.title = .init(localized: title)
        self.icon = icon
        self.isDestructive = isDestructive
        self.visibility = visibility
    }
    
    @_disfavoredOverload
    public init(
        _ title: String,
        icon: Icon,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.visibility = visibility
    }
}
