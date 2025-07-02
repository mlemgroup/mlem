//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Reply1Snapshot {
    init(from commentReply: PieFedCommentReply) throws(ApiClientError) {
        self.id = commentReply.id
        self.recipientId = commentReply.recipientId
        self.commentId = commentReply.commentId
        self.read = commentReply.read
        self.created = commentReply.published
        self.isMention = false
    }
}
