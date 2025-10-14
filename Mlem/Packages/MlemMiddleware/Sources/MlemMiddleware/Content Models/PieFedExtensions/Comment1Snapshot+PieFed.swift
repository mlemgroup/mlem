//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Comment1Snapshot {
    init(from comment: PieFedComment) throws(ApiClientError) {
        let parentCommentIds = comment.path
            .split(separator: ".")
            .dropFirst()
            .dropLast()
            .compactMap { Int($0) }

        self.init(
            actorId: comment.apId,
            id: comment.id,
            creatorId: comment.userId,
            postId: comment.postId,
            parentCommentIds: parentCommentIds,
            created: comment.published,
            content: comment.body,
            updated: comment.updated,
            distinguished: comment.distinguished ?? false,
            languageId: comment.languageId,
            // If a post is removed, deleted is true for some reason
            deleted: comment.removed ? false : comment.deleted,
            removed: comment.removed
        )
    }
}
