//
//  MessageTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation

class MessageTracker: ChildTracker<MessageModel> {
    @Dependency(\.inboxRepository) var inboxRepository
    
    typealias Item = MessageModel
    typealias ParentType = InboxItemNew
    
    override func fetchPage(page: Int) async throws -> [Item] {
        try await inboxRepository.loadMessages(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly ?? false)
    }
}
