//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension PersonalUnreadCountSnapshot {
    init(from response: LemmyGetUnreadCountResponse) throws(ApiClientError) {
        self.replies = response.replies
        self.mentions = response.mentions
        self.messages = response.privateMessages
    }
}
