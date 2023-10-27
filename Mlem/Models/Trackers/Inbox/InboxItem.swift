//
//  InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

/// Enumeration of content models that can appear in the inbox
enum InboxItem {
    case message(MessageModel)
    case mention(MentionModel)
    case reply(ReplyModel)

    var published: Date {
        switch self {
        case let .message(message):
            return message.privateMessage.published
        case let .mention(mention):
            return mention.personMention.published
        case let .reply(reply):
            return reply.commentReply.published
        }
    }

    var uid: ContentModelIdentifier {
        switch self {
        case let .message(message):
            return message.uid
        case let .mention(mention):
            return mention.uid
        case let .reply(reply):
            return reply.uid
        }
    }
    
    var creatorId: Int {
        switch self {
        case let .message(message):
            return message.privateMessage.creatorId
        case let .mention(mention):
            return mention.comment.creatorId
        case let .reply(reply):
            return reply.comment.creatorId
        }
    }
    
    var read: Bool {
        switch self {
        case let .message(message):
            return message.privateMessage.read
        case let .mention(mention):
            return mention.personMention.read
        case let .reply(reply):
            return reply.commentReply.read
        }
    }
    
//    func markRead(unreadTracker: UnreadTracker) async {
//        switch self {
//        case let .message(message):
//            if !message.privateMessage.read {
//                await message.toggleRead(unreadTracker: unreadTracker)
//            }
//        case let .mention(mention):
//            if !mention.personMention.read {
//                await mention.toggleRead(unreadTracker: unreadTracker)
//            }
//        case let .reply(reply):
//            if !reply.commentReply.read {
//                await reply.toggleRead(unreadTracker: unreadTracker)
//            }
//        }
//    }
}

extension InboxItem: Identifiable {
    var id: Int {
        switch self {
        case let .message(message):
            return message.id
        case let .mention(mention):
            return mention.id
        case let .reply(reply):
            return reply.id
        }
    }
}

extension InboxItem: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(published)
        }
    }
}
