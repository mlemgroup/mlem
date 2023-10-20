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
