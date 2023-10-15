//
//  ReplyTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation

class ReplyTrackerNew: BasicTracker<ReplyModel>, ChildTrackerProtocol {
    @Dependency(\.inboxRepository) var inboxRepository

    typealias Item = ReplyModel
    typealias ParentType = InboxItemNew
    
    var cursor: Int = 0
    var parentTracker: ParentTracker<ParentType>?
    
    override init(internetSpeed: InternetSpeed, unreadOnly: Bool, sortType: TrackerSortType) {
        super.init(internetSpeed: internetSpeed, unreadOnly: unreadOnly, sortType: sortType)
    }
    
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

extension ReplyModel: ChildTrackerItemProtocol {
    typealias ParentType = InboxItemNew
    
    func toParent() -> ParentType {
        .reply(self)
    }
}
