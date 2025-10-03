//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension InboxNotificationSnapshot {
    init(from replyView: LemmyCommentReplyView) throws(ApiClientError) {
        self.init(
            id: LegacyNotificationIdWrapper(type: .reply, id: replyView.commentReply.id).hashValue,
            read: replyView.commentReply.read
        )
    }

    init(from mentionView: LemmyPersonCommentMentionView) throws(ApiClientError) {
        self.init(
            id: LegacyNotificationIdWrapper(type: .mention, id: mentionView.personMention.id).hashValue,
            read: mentionView.personMention.read
        )
    }

    init(from messageView: LemmyPrivateMessageView) throws(ApiClientError) {
        guard let read = messageView.privateMessage.read else {
            throw .responseMissingRequiredData("LemmyPrivateMessage read")
        }

        self.init(
            id: LegacyNotificationIdWrapper(type: .message, id: messageView.privateMessage.id).hashValue,
            read: read
        )
    }
}

// This can be removed once we drop support for < Lemmy 1.0
private struct LegacyNotificationIdWrapper: Hashable {
    enum NotificationType: Hashable {
        case reply, mention, message
    }

    let type: NotificationType
    let id: Int
}
