//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-12.
//

import Foundation

public enum InboxNotificationContent {
    case reply(Comment2)
    case mention(Comment2)
    case message(Message2)
    
    public var wrappedValue: any ContentModel & ActorIdentifiable {
        switch self {
        case let .reply(comment2): comment2
        case let .mention(comment2): comment2
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
    
    func takeSnapshot() -> InboxNotificationContentSnapshot {
        switch self {
        case let .reply(comment): .reply(comment.takeSnapshot2())
        case let .mention(comment): .mention(comment.takeSnapshot2())
        case let .message(message): .message(message.takeSnapshot2())
        }
    }
}

public enum InboxNotificationContentType: Hashable {
    case reply, mention, message
}
