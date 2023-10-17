//
//  MessageModel+ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//

import Foundation

extension MessageModel: ChildTrackerItem {
    typealias ParentType = InboxItemNew
    
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
