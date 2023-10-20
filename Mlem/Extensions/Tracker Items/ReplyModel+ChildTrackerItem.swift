//
//  ReplyModel+ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

extension ReplyModel: ChildTrackerItem {
    typealias ParentType = InboxItem

    func toParent() -> ParentType {
        .reply(self)
    }

    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(commentReply.published)
        }
    }
}
