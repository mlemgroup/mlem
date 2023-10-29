//
//  MessageTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Dependencies
import Foundation

class MessageTracker: ChildTracker<MessageModel, AnyInboxItem> {
    @Dependency(\.inboxRepository) var inboxRepository
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }

    override func fetchPage(page: Int) async throws -> [MessageModel] {
        try await inboxRepository.loadMessages(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly)
    }
    
    override func toParent(item: MessageModel) -> AnyInboxItem {
        .message(item)
    }
}
