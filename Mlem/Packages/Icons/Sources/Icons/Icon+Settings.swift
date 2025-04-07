//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-06.
//

import Foundation

public extension Icon {
    struct SettingsIcons {
        public let hideRead: Icon = .applyFill("book")
        @inlinable public var showRead: Icon { hideRead }
    }
    
    static let settings: SettingsIcons = .init()
}
