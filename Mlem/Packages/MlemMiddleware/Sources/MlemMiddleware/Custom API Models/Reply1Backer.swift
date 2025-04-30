//
//  Reply1ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public struct Reply1Backer: CacheIdentifiable, Identifiable {
    public let id: Int
    public let recipientId: Int
    public let commentId: Int
    public let read: Bool
    public let published: Date
    
    public var cacheId: Int { id }

    public init(from commentReply: ApiCommentReply) {
        self.id = commentReply.id
        self.recipientId = commentReply.recipientId
        self.commentId = commentReply.commentId
        self.read = commentReply.read
        self.published = commentReply.published
    }
    
    public init(from personMention: ApiPersonMention) {
        self.id = personMention.id
        self.recipientId = personMention.recipientId
        self.commentId = personMention.commentId
        self.read = personMention.read
        self.published = personMention.published
    }
}
