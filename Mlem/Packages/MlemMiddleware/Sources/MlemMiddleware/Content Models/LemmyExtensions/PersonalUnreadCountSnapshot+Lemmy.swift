//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension PersonalUnreadCountSnapshot {
    init(from response: LemmyGetUnreadCountResponse) throws(ApiClientError) {
        guard let replies = response.replies, let mentions = response.mentions, let messages = response.privateMessages else {
            throw ApiClientError.featureUnsupported
        }
        self.replies = replies
        self.mentions = mentions
        self.messages = messages
    }
}
