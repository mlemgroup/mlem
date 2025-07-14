//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Message2Snapshot {
    init(from message: LemmyPrivateMessageView) throws(ApiClientError) {
        self.message = try .init(from: message.privateMessage)
        self.creator = try .init(from: message.creator)
        self.recipient = try .init(from: message.recipient)
    }
}
