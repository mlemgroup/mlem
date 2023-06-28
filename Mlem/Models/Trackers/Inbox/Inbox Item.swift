//
//  Inbox Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

/**
 Protocol for items in the inbox to allow a unified, sorted feed
 */
struct InboxItem: Identifiable {
    let published: Date
    let id: Int
    let type: InboxItemType
}

extension InboxItem: Comparable {
    static func == (lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.published < rhs.published
    }
}
