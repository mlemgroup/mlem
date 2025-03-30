//
//  InboxFetcher.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-24.
//

import Foundation

@Observable
public class InboxFetcher: Fetcher<InboxItem> {
    var unreadOnly: Bool
    
    init(api: ApiClient, pageSize: Int, unreadOnly: Bool) {
        self.unreadOnly = unreadOnly
        super.init(api: api, pageSize: pageSize)
    }
    
    /// Updates fetching behavior to hide read items. Assumes items will NOT be cleared from the associated FeedLoader and that deduping will be handled by that FeedLoader.
    /// - Parameter unreadCount: number of unread items still present after client-side filtering
    func hideRead(unreadCount: Int) {
        guard !unreadOnly else {
            assertionFailure("Cannot hide read (unreadOnly already true)")
            return
        }
        
        unreadOnly = true
        page = Int(floor(Double(unreadCount / pageSize)))
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
