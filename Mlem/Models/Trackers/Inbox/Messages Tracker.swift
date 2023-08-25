//
//  Messages Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

@MainActor
class MessagesTracker: FeedTracker<APIPrivateMessageView>, InboxTracker {
    func loadNextPage(account: SavedAccount, unreadOnly: Bool = false) async throws {
        try await perform(
            GetPrivateMessagesRequest(
                account: account,
                page: page,
                limit: internetSpeed.pageSize,
                unreadOnly: unreadOnly
            )
        )
    }
    
    func refresh(account: SavedAccount, unreadOnly: Bool = false) async throws {
        try await refresh(
            GetPrivateMessagesRequest(
                account: account,
                page: 1,
                limit: internetSpeed.pageSize,
                unreadOnly: unreadOnly
            )
        )
    }
}
