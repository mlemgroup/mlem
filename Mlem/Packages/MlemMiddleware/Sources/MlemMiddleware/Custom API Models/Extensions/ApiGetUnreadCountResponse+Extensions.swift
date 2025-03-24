//
//  ApiGetUnreadCountResponse+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-15.
//

import Foundation

extension ApiGetUnreadCountResponse: UnreadCount.DictionaryConvertible {
    var unreadCountDictionary: [InboxItemType: Int] {
        [
            .reply: replies ?? 0,
            .mention: mentions ?? 0,
            .message: privateMessages ?? 0
        ]
    }
}
