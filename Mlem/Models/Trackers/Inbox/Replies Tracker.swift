//
//  Replies Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

@MainActor
class RepliesTracker: FeedTracker<APICommentReplyView>, InboxTracker {
    
    func loadNextPage(account: SavedAccount, unreadOnly: Bool = false) async throws {
        try await perform(
            GetRepliesRequest(
                account: account,
                sort: .new,
                page: page,
                limit: 50,
                unreadOnly: unreadOnly
            )
        )
    }
    
    func refresh(account: SavedAccount, unreadOnly: Bool = false) async throws {
        try await refresh(
            GetRepliesRequest(
                account: account,
                sort: .new,
                page: 1,
                limit: 50,
                unreadOnly: unreadOnly
            )
        )
    }
}
