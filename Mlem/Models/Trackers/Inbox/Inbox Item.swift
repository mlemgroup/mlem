//
//  Inbox Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

/**
 Wrapper for items in the inbox to allow a unified, sorted feed
 */
struct InboxItem: Identifiable {
    let published: Date
    let baseId: Int
    var id: Int { hashId() }
    let read: Bool
    let type: InboxItemType
    
    private func hashId() -> Int {
        var hasher = Hasher()
        hasher.combine(baseId)
        hasher.combine(type.hasherId)
        return hasher.finalize()
    }
}

extension InboxItem: Comparable {
    static func == (lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.published < rhs.published
    }
}
