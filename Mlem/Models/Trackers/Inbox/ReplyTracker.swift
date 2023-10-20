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

    override func fetchPage(page: Int) async throws -> [Item] {
        try await inboxRepository.loadReplies(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly ?? false)
    }
}
