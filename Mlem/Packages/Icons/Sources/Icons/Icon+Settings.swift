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
        
        public let postSize: Icon = .applyFill("rectangle.expand.vertical")
        public let postSizeCompact: Icon = .applyFill("rectangle.grid.1x2")
        public let postSizeTiled: Icon = .applyFill("rectangle.grid.2x2")
        public let postSizeHeadline: Icon = .applyFill("rectangle")
        public let postSizeLarge: Icon = .applyFill("text.below.photo")
        
        public let blurNsfw: Icon = .applyFill("eye.trianglebadge.exclamationmark")
    }
    
    static let settings: SettingsIcons = .init()
}
