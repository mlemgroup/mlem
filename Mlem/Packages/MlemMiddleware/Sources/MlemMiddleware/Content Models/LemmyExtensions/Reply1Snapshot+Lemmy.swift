//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Reply1Snapshot {
    init(from commentReply: LemmyCommentReply) throws(ApiClientError) {
        self.init(
            id: commentReply.id,
            recipientId: commentReply.recipientId,
            commentId: commentReply.commentId,
            created: commentReply.published,
            isMention: false,
            read: commentReply.read
        )
    }
    
    init(from personMention: LemmyPersonCommentMention) throws(ApiClientError) {
        self.init(
            id: personMention.id,
            recipientId: personMention.recipientId,
            commentId: personMention.commentId,
            created: personMention.published,
            isMention: true,
            read: personMention.read
        )
    }
}
