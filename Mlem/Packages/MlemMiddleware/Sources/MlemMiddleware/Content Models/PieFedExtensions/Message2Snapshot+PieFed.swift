//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Message2Snapshot {
    init(from message: PieFedPrivateMessageView) throws(ApiClientError) {
        self.message = try .init(from: message.privateMessage)
        self.creator = try .init(from: message.creator)
        self.recipient = try .init(from: message.recipient)
    }
}
