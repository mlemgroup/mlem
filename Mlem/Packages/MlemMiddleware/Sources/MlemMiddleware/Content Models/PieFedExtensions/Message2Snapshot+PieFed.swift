//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Message2Snapshot {
    init(from message: PieFedPrivateMessageView) throws(ApiClientError) {
        try self.init(
            message: .init(from: message.privateMessage),
            creator: .init(from: message.creator),
            recipient: .init(from: message.recipient)
        )
    }
}
