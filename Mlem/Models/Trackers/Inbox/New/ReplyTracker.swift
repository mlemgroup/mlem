//
//  ReplyTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation

class ReplyTracker: ChildTracker<ReplyModel> {
    @Dependency(\.inboxRepository) var inboxRepository

    typealias Item = ReplyModel
    typealias ParentType = InboxItemNew
    
    var cursor: Int = 0
    var parentTracker: ParentTracker<ParentType>?
    
    override func fetchPage(page: Int) async throws -> [Item] {
        try await inboxRepository.loadReplies(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly ?? false)
    }
}

extension ReplyModel: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(commentReply.published)
        }
    }
}

extension ReplyModel: ChildTrackerItem {
    typealias ParentType = InboxItemNew
    
    func toParent() -> ParentType {
        .reply(self)
    }
}
