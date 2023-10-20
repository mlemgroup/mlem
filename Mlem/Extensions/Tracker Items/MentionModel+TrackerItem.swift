//
//  MentionModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension MentionModel: ChildTrackerItem {
    typealias ParentType = InboxItem

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
