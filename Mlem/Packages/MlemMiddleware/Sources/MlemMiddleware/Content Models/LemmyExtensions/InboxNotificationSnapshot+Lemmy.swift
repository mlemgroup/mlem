//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension InboxNotificationSnapshot {
    init(from replyView: LemmyCommentReplyView) throws(ApiClientError) {
        try self.init(
            id: LegacyNotificationIdWrapper(type: .reply, id: replyView.commentReply.id).hashValue,
            contentId: replyView.commentReply.id,
            read: replyView.commentReply.read,
            content: .reply(.init(from: replyView))
        )
    }

    init(from mentionView: LemmyPersonCommentMentionView) throws(ApiClientError) {
        try self.init(
            id: LegacyNotificationIdWrapper(type: .mention, id: mentionView.personMention.id).hashValue,
            contentId: mentionView.personMention.id,
            read: mentionView.personMention.read,
            content: .mention(.init(from: mentionView))
        )
    }

    init(from messageView: LemmyPrivateMessageView) throws(ApiClientError) {
        guard let read = messageView.privateMessage.read else {
            throw .responseMissingRequiredData("LemmyPrivateMessage read")
        }

        try self.init(
            id: LegacyNotificationIdWrapper(type: .message, id: messageView.privateMessage.id).hashValue,
            contentId: messageView.privateMessage.id,
            read: read,
            content: .message(.init(from: messageView))
        )
    }
}

// This can be removed once we drop support for < Lemmy 1.0
private struct LegacyNotificationIdWrapper: Hashable {
    let type: InboxNotificationContentType
    let id: Int
}
