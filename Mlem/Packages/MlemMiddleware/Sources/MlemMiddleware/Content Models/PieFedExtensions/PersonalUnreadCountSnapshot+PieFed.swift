//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-04.
//

import Foundation

public extension PersonalUnreadCountSnapshot {
    init(from response: PieFedGetUnreadCountResponse) throws(ApiClientError) {
        self.replies = response.replies
        self.mentions = response.mentions
        self.messages = response.privateMessages
    }
}
