//
//  Icon+Uptime.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-08.
//

import Foundation

public extension Icon {
    struct UptimeIcons {
        public let offline: Icon = .init("xmark.circle")
        public let online: Icon = .init("checkmark.circle")
        public let outage: Icon = .init("exclamationmark.circle")
    }
    
    static let uptime: UptimeIcons = .init()
}
