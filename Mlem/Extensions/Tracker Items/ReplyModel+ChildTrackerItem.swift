//
//  ReplyModel+ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

extension ReplyModel: ChildTrackerItem, InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { commentReply.published }
    
    var creatorId: Int { comment.creatorId }
    
    var read: Bool { commentReply.read }

    func toParent() -> ParentType {
        AnyInboxItem(self)
    }

    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(commentReply.published)
        }
    }
}
