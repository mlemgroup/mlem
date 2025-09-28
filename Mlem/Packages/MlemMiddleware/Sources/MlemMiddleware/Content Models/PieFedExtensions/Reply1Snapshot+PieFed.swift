//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Reply1Snapshot {
    init(from commentReply: PieFedCommentReply, isMention: Bool) throws(ApiClientError) {
        self.init(
            id: commentReply.id,
            recipientId: commentReply.recipientId,
            commentId: commentReply.commentId,
            created: commentReply.published,
            isMention: isMention,
            read: commentReply.read
        )
    }
}
