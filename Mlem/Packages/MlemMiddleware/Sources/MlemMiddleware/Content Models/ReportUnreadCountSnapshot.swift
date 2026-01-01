//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct ReportUnreadCountSnapshot {
    let comments: Int
    let posts: Int
    let messages: Int
    
    init(from response: LemmyGetReportCountResponse) throws(ApiClientError) {
        self.comments = response.commentReports ?? 0
        self.posts = response.postReports ?? 0
        self.messages = response.privateMessageReports ?? 0
    }
    
    var unreadCountDictionary: [InboxItemType: Int] {
        [
            .postReport: posts,
            .commentReport: comments,
            .messageReport: messages
        ]
    }
}
