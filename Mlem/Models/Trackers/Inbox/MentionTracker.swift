//
//  MentionTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Dependencies
import Foundation

class MentionTracker: ChildTracker<MentionModel, AnyInboxItem> {
    @Dependency(\.inboxRepository) var inboxRepository
    
    var unreadOnly: Bool
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }

    override func fetchPage(page: Int) async throws -> [MentionModel] {
        try await inboxRepository.loadMentions(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly)
    }
    
    override func toParent(item: MentionModel) -> AnyInboxItem {
        .mention(item)
    }
}
