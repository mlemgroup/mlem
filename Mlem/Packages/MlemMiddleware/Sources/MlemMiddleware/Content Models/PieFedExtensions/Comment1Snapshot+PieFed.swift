//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Comment1Snapshot {
    init(from comment: PieFedComment) throws(ApiClientError) {
        self.actorId = comment.apId
        self.id = comment.id
        self.creatorId = comment.userId
        self.postId = comment.postId
        self.parentCommentIds = comment.path
            .split(separator: ".")
            .dropFirst()
            .dropLast()
            .compactMap { Int($0) }
        
        self.created = comment.published
        
        self.content = comment.body
        self.updated = comment.updated
        self.distinguished = comment.distinguished ?? false
        self.languageId = comment.languageId
        self.deleted = comment.deleted
        self.removed = comment.removed
    }
}
