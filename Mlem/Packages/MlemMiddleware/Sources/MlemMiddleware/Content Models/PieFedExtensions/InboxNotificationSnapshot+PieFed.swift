//
//  InboxNotificationSnapshot+PieFed.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-12-22.
//

import Foundation

extension InboxNotificationSnapshot {
    init(from replyView: PieFedCommentReplyView) throws(ApiClientError) {
        try self.init(
            id: LegacyNotificationIdWrapper(type: .reply, id: replyView.commentReply.id).hashValue,
            contentId: replyView.commentReply.id,
            read: replyView.commentReply.read,
            content: .reply(.init(from: replyView))
        )
    }
}

// This can be removed once we drop support for < Lemmy 1.0
private struct LegacyNotificationIdWrapper: Hashable {
    let type: InboxNotificationContentType
    let id: Int
}
