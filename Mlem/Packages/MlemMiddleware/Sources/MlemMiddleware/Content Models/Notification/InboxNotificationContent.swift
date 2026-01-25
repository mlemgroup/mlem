//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-12.
//

import Foundation

public enum InboxNotificationContent {
    case reply(Comment)
    case mention(Comment)
    case message(Message2)
    
    public var wrappedValue: any ContentModel & ActorIdentifiable {
        switch self {
        case let .reply(comment): comment
        case let .mention(comment): comment
        case let .message(message2): message2
        }
    }
    
    public var type: InboxNotificationContentType {
        switch self {
        case .reply: .reply
        case .mention: .mention
        case .message: .message
        }
    }
    
    func takeSnapshot() -> InboxNotificationContentSnapshot? {
        switch self {
        case let .reply(comment):
            if let snapshot = comment.takeSnapshot2() {
                .reply(snapshot)
            } else {
                nil
            }
        case let .mention(comment):
            if let snapshot = comment.takeSnapshot2() {
                .mention(snapshot)
            } else {
                nil
            }
        case let .message(message): .message(message.takeSnapshot2())
        }
    }
}

public enum InboxNotificationContentType: Hashable {
    case reply, mention, message
}
