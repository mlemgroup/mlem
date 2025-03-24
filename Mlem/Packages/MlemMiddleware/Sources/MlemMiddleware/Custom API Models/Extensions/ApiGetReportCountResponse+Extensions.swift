//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-15.
//

import Foundation

extension ApiGetReportCountResponse: UnreadCount.DictionaryConvertible {
    var unreadCountDictionary: [InboxItemType: Int] {
        [
            .postReport: postReports ?? 0,
            .commentReport: commentReports ?? 0,
            .messageReport: privateMessageReports ?? 0
        ]
    }
}
