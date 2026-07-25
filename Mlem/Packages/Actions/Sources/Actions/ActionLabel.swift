//
//  ActionLabel.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-25.
//

import Foundation
import Icons

public struct ActionLabel {
    public let title: String
    public let icon: Icon

    public init(_ title: LocalizedStringResource, icon: Icon) {
        self.title = .init(localized: title)
        self.icon = icon
    }
    
    @_disfavoredOverload
    public init(_ title: some StringProtocol, icon: Icon) {
        self.title = String(title)
        self.icon = icon
    }
}
