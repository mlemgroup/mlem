//
//  MentionModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension MentionModel: ChildTrackerItem, InboxItem {
    typealias ParentType = AnyInboxItem
    
    var published: Date { personMention.published }
    
    var creatorId: Int { comment.creatorId }
    
    var read: Bool { personMention.read }

    func toParent() -> ParentType {
        .mention(self)
    }

    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(personMention.published)
        }
    }
}
