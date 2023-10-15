//
//  MessageTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation

class MessageTrackerNew: BasicTracker<MessageModel>, ChildTrackerProtocol {
    @Dependency(\.inboxRepository) var inboxRepository
    
    typealias Item = MessageModel
    typealias ParentType = InboxItemNew
    
    var cursor: Int = 0
    var parentTracker: ParentTracker<ParentType>?
    
    override init(internetSpeed: InternetSpeed, unreadOnly: Bool, sortType: TrackerSortType) {
        super.init(internetSpeed: internetSpeed, unreadOnly: unreadOnly, sortType: sortType)
    }
    
    override func fetchPage(page: Int) async throws -> [Item] {
        try await inboxRepository.loadMessages(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly ?? false)
    }
}

// note: I have put these extensions here, rather than in MessageModel, to consolidate the logic required to conform MessageTracker to ChildTrackerProtocol. This should also allow this file to serve as a better template for creating other ChildTrackers.

extension MessageModel: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(privateMessage.published)
        }
    }
}

extension MessageModel: ChildTrackerItemProtocol {
    typealias ParentType = InboxItemNew
    
    func toParent() -> ParentType {
        .message(self)
    }
}
