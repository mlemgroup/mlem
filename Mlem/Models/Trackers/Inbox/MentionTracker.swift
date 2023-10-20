//
//  MentionTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Dependencies
import Foundation

class MentionTracker: ChildTracker<MentionModel> {
    @Dependency(\.inboxRepository) var inboxRepository

    typealias Item = MentionModel
    typealias ParentType = InboxItem

    override func fetchPage(page: Int) async throws -> [Item] {
        try await inboxRepository.loadMentions(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly ?? false)
    }
}
