//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Message2Snapshot {
    init(from message: LemmyPrivateMessageView) throws(ApiClientError) {
        try self.init(
            message: .init(from: message.privateMessage),
            creator: .init(from: message.creator),
            recipient: .init(from: message.recipient)
        )
    }
}
