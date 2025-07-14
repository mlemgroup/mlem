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
        
        if let published = commentReply.publishedAt ?? commentReply.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyCommentReply published")
        }
        
        self.isMention = false
    }
    
    init(from personMention: LemmyPersonCommentMention) throws(ApiClientError) {
        self.id = personMention.id
        self.recipientId = personMention.recipientId
        self.commentId = personMention.commentId
        self.read = personMention.read
        
        if let published = personMention.publishedAt ?? personMention.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyPersonCommentMention published")
        }
        
        self.isMention = true
    }
}
