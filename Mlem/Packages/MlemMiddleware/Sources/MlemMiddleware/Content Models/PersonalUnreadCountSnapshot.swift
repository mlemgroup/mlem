//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct PersonalUnreadCountSnapshot {
    let replies: Int
    let mentions: Int
    let messages: Int
    
    public init(from response: ApiGetUnreadCountResponse) throws(ApiClientError) {
        guard let replies = response.replies, let mentions = response.mentions, let messages = response.privateMessages else {
            throw ApiClientError.unsupportedLemmyVersion
        }
        self.replies = replies
        self.mentions = mentions
        self.messages = messages
    }
    
    var unreadCountDictionary: [InboxItemType: Int] {
        [
            .reply: replies,
            .mention: mentions,
            .message: messages
        ]
    }
}
