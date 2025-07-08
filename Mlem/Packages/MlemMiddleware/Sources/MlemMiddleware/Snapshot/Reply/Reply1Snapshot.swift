//
//  Reply1ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public struct Reply1Snapshot: CacheIdentifiable, Identifiable {
    // Won't change.
    public let id: Int
    public let recipientId: Int
    public let commentId: Int
    public let created: Date
    public let isMention: Bool
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Reply1!
    public let read: Bool
    
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(isMention)
        return hasher.finalize()
    }

    public init(from commentReply: LemmyCommentReply) throws(ApiClientError) {
        self.id = commentReply.id
        self.recipientId = commentReply.recipientId
        self.commentId = commentReply.commentId
        self.read = commentReply.read
        self.created = commentReply.published
        self.isMention = false
    }
    
    public init(from personMention: LemmyPersonCommentMention) throws(ApiClientError) {
        self.id = personMention.id
        self.recipientId = personMention.recipientId
        self.commentId = personMention.commentId
        self.read = personMention.read
        self.created = personMention.published
        self.isMention = true
    }
}
