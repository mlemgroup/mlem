//
//  InboxFetcher.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-24.
//

import Foundation

@Observable
public class InboxFetcher: Fetcher<InboxNotification> {
    var unreadOnly: Bool
    
    init(api: ApiClient, pageSize: Int, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(api: api, pageSize: pageSize)
    }
    
    /// Updates fetching behavior to hide read posts. Assumes associated FeedLoader will immediately perform a refresh.
    func hideRead() {
        guard !unreadOnly else {
            assertionFailure("Cannot hide read (unreadOnly already true)")
            return
        }
        
        unreadOnly = true
    }
    
    /// Updates fetching behavior to show read posts. Assumes associated FeedLoader will immediately perform a refresh.
    func showRead() {
        guard unreadOnly else {
            assertionFailure("Cannot show read (unreadOnly already false)")
            return
        }
        
        unreadOnly = false
    }
}
