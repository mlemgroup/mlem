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
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortVal.Case, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }

    override func fetchPage(page: Int) async throws -> FetchResponse<MessageModel> {
        // TODO: can this return a cursor?
        let newItems = try await inboxRepository.loadMessages(page: page, limit: internetSpeed.pageSize, unreadOnly: unreadOnly)
        return .init(items: newItems, cursor: nil, numFiltered: 0)
    }
    
    override func toParent(item: MessageModel) -> AnyInboxItem {
        .message(item)
    }
}
