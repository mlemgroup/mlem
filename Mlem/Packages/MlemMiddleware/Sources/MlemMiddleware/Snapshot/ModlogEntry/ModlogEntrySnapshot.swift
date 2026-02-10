//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-13.
//

import Foundation

public struct ModlogEntrySnapshot {
    public let created: Date
    public let moderator: Person1Snapshot?
    public let type: ModlogEntryContentSnapshot
    
    public init(created: Date, moderator: Person1Snapshot?, type: ModlogEntryContentSnapshot) {
        self.created = created
        self.moderator = moderator
        self.type = type
    }
}
