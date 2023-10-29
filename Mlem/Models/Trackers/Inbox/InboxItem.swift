//
//  InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

protocol InboxItem: Identifiable, ContentIdentifiable, TrackerItem {
    var published: Date { get }
    var uid: ContentModelIdentifier { get }
    var creatorId: Int { get }
    var read: Bool { get }
}

class AnyInboxItem: InboxItem {
    let wrappedValue: any InboxItem
    init(_ wrappedValue: any InboxItem) {
        self.wrappedValue = wrappedValue
    }
    
    var uid: ContentModelIdentifier { wrappedValue.uid }
    var published: Date { wrappedValue.published }
    var creatorId: Int { wrappedValue.creatorId }
    var read: Bool { wrappedValue.read }
    
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal { wrappedValue.sortVal(sortType: sortType) }
    
    static func == (lhs: AnyInboxItem, rhs: AnyInboxItem) -> Bool {
        lhs.uid == rhs.uid
    }
}
