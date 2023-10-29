//
//  MessageModel+ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

extension MessageModel: ChildTrackerItem, InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { privateMessage.published }
    
    var creatorId: Int { privateMessage.creatorId }
    
    var read: Bool { privateMessage.read }

    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(privateMessage.published)
        }
    }

    func toParent() -> ParentType {
        .message(self)
    }
}
