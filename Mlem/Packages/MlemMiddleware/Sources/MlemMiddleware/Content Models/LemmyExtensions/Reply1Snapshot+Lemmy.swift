//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Reply1Snapshot {
    init(from commentReply: LemmyCommentReply) throws(ApiClientError) {
        self.id = commentReply.id
        self.recipientId = commentReply.recipientId
        self.commentId = commentReply.commentId
        self.read = commentReply.read
        self.created = commentReply.published
        self.isMention = false
    }
    
    init(from personMention: LemmyPersonCommentMention) throws(ApiClientError) {
        self.id = personMention.id
        self.recipientId = personMention.recipientId
        self.commentId = personMention.commentId
        self.read = personMention.read
        self.created = personMention.published
        self.isMention = true
    }
}
