//
//  InboxItemNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

/// Enumeration of content models that can appear in the inbox
enum InboxItemNew {
    case message(MessageModel)
    case mention(MentionModel)
    case reply(ReplyModel)

    // TODO: support for multiple sorting types--need protocols and such
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
}

extension InboxItemNew: Identifiable {
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

/// InboxItemNew but with no associated type
enum InboxItemTypeNew {
    case message, mention, reply
}

extension InboxItemNew: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(published)
        }
    }
}
