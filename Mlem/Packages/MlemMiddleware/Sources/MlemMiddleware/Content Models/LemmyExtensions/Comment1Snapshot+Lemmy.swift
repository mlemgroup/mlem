//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Comment1Snapshot {
    init(from comment: LemmyComment) throws(ApiClientError) {
        let parentCommentIds = comment.path
            .split(separator: ".")
            .dropFirst()
            .dropLast()
            .compactMap { Int($0) }
        
        guard let published = comment.publishedAt ?? comment.published else {
            throw .responseMissingRequiredData("LemmyComment published")
        }
        
        self.init(
            actorId: comment.apId,
            id: comment.id,
            creatorId: comment.creatorId,
            postId: comment.postId,
            parentCommentIds: parentCommentIds,
            created: published,
            content: comment.content,
            updated: comment.updatedAt ?? comment.updated,
            distinguished: comment.distinguished,
            languageId: comment.languageId,
            deleted: comment.deleted,
            removed: comment.removed
        )
    }
}
