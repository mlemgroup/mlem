//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Comment1Snapshot {
    init(from comment: LemmyComment) throws(ApiClientError) {
        self.actorId = comment.apId
        self.id = comment.id
        self.creatorId = comment.creatorId
        self.postId = comment.postId
        self.parentCommentIds = comment.path
            .split(separator: ".")
            .dropFirst()
            .dropLast()
            .compactMap { Int($0) }
        
        if let published = comment.publishedAt ?? comment.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyComment published")
        }
        
        self.content = comment.content
        
        self.updated = comment.updatedAt ?? comment.updated
        
        self.distinguished = comment.distinguished
        self.languageId = comment.languageId
        self.deleted = comment.deleted
        self.removed = comment.removed
    }
}
