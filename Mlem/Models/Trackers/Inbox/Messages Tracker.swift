//
//  Messages Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

@MainActor
class MessagesTracker: FeedTracker<APIPrivateMessageView>, InboxTracker {
    
    func loadNextPage(account: SavedAccount, unreadOnly: Bool = false) async throws {
        try await perform(
            GetPrivateMessagesRequest(
                account: account,
                page: page,
                limit: 50,
                unreadOnly: unreadOnly
            )
        )
    }
    
    func refresh(account: SavedAccount, unreadOnly: Bool = false) async throws {
        try await refresh(
            GetPrivateMessagesRequest(
                account: account,
                page: 1,
                limit: 50,
                unreadOnly: unreadOnly
            )
        )
    }
}
