//
//  InboxNotificationSnapshot+PieFed.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-12-22.
//

import Foundation

extension InboxNotificationSnapshot {
    init(from replyView: PieFedCommentReplyView, isMention: Bool) throws(ApiClientError) {
        try self.init(
            id: LegacyNotificationIdWrapper(type: isMention ? .mention : .reply, id: replyView.commentReply.id).hashValue,
            contentId: replyView.commentReply.id,
            read: replyView.commentReply.read,
            content: .reply(.init(from: replyView))
        )
    }

    init(from messageView: PieFedPrivateMessageView) throws(ApiClientError) {
        try self.init(
            id: LegacyNotificationIdWrapper(type: .message, id: messageView.privateMessage.id).hashValue,
            contentId: messageView.privateMessage.id,
            read: messageView.privateMessage.read,
            content: .message(.init(from: messageView))
        )
    }
}

// This can be removed once we drop support for < Lemmy 1.0
private struct LegacyNotificationIdWrapper: Hashable {
    let type: InboxNotificationContentType
    let id: Int
}
